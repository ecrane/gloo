# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# The persistence manager.
# Keeps a collection of object-file mappings, and then
# uses mappings to know how/where to save updated objects.
#

module Gloo
  module Persist
    class PersistMan

      attr_reader :maps, :mech

      OBJ_NOT_FOUND_ERR = 'Could not resolve object to save: '.freeze
      PATH_EXISTS_ERR = 'Will not overwrite a file not already saved there: '.freeze
      RELOAD_DIRTY_WARNING = 'Reloading will discard unsaved changes in: '.freeze

      #
      # Constructor for the persistence manager.
      #
      def initialize( engine )
        @engine = engine
        @maps = []
        @mech = @engine.platform.get_file_mech( @engine )
      end

      #
      # Save one object to the file, or every open file if no name is
      # given.
      #
      def save( name = '' )
        name.blank? ? save_all : save_one( name )
      end

      #
      # Save every open file.
      #
      def save_all
        save_batch( @maps )
      end

      #
      # Save the given object: every file that owns a declaration in
      # its root's tree (usually one -- more when the root is a
      # multi-file namespace). If it isn't mapped to any file yet, it's
      # saved fresh to a default path derived from its root's name.
      #
      def save_one( name )
        obj = resolve_for_save( name )
        return unless obj

        fs_list = find_file_storages( obj )
        return save_new( obj, @mech.resolve_save_path( root_of( obj ).name ) ) if fs_list.empty?

        @engine.event_manager.on_save obj
        save_batch( fs_list )
      end

      #
      # Save the given object to an explicit path. Registers the
      # mapping so a future bare save includes it. Refuses to overwrite
      # a file that exists but isn't already mapped to this object.
      #
      def save_to( name, path )
        obj = resolve_for_save( name )
        return unless obj

        pn = @mech.resolve_save_path( path )
        mapped = @maps.find { |fs| fs.pn == pn }
        return save_mapped( obj, mapped, pn ) if mapped
        return @engine.err( "#{PATH_EXISTS_ERR}#{pn}" ) if @mech.exist?( pn )

        save_new( obj, pn )
      end

      #
      # Load the object from the file.
      #
      def load( name )
        pns = get_full_path_names name
        return unless pns

        pns.each do |pn|
          @engine.log.debug "Load file(s) at: #{pn}"
          begin
            fs = Gloo::Persist::FileStorage.new( @engine, pn )
            fs.load
            next unless fs.obj # a failed load -- don't map it

            @maps << fs
            @engine.event_manager.on_load fs.obj
          rescue => ex
            @engine.handle_exception( ex )
          end
        end
      end

      # 
      # Unload all loaded objects.
      # The engine  is reset to a clean state.
      # 
      def unload_all
        objs = self.maps.map( &:obj ).compact
        objs.each( &:msg_unload )
        @engine.reset_state
      end

      # 
      # The given object is unloading.
      # Do any necessary clean up here.
      # This is used to unload a single object and comes from a
      # message sent to the object.
      # 
      def unload( obj )
        @engine.event_manager.on_unload obj
        @engine.heap.unload obj
        # Drop every mapping for this object -- more than one when the
        # root came from several files (the namespace pattern) -- and
        # sweep out any mapping whose object is already gone.
        @maps.reject! { |o| o.obj.nil? || ( o.obj.pn === obj.pn ) }
      end

      #
      # Reload all objects.
      # First send a message to each object to let it know it is being reloaded.
      # Then let the engine restart to reload the files.
      #
      def reload_all
        return unless @maps

        @maps.each { |fs| warn_if_dirty( fs ) }
        @maps.each do |fs|
          @engine.event_manager.on_reload fs.obj
        end

        # Actual unloading is done in the engine.restart.
        @engine.restart
      end

      #
      # Re-load the given object from file.
      # This is used to reload a single object and comes from a
      # message sent to the object.
      #
      def reload( obj )
        fs = find_file_storage( obj )
        return unless fs

        warn_if_dirty( fs )
        @engine.event_manager.on_reload obj
        @engine.heap.unload obj
        fs.load
      end

      #
      # Find the objects FileStorage in the list.
      #
      def find_file_storage( obj )
        @maps.each do |o|
          return o if ( o.obj.pn === obj.pn )
        end

        # It was not found, so return nil.
        return nil
      end

      #
      # Find every FileStorage that owns a declaration in the given
      # object's root -- usually one, more when the root is shared
      # across files (the multi-file namespace pattern).
      #
      def find_file_storages( obj )
        root = root_of( obj )
        return @maps.select { |fs| fs.roots.include?( root ) }
      end


      #
      # Get the full path and name of the file.
      #
      def get_full_path_names( name )
        return nil if name.strip.empty?

        if name.strip[ -1 ] == '*'
          return @mech.get_all_files_in( name[ 0..-2 ] )
        else
          return @mech.expand( name )
        end
      end

      #
      # Check to see if a given path name refers to a gloo object file.
      #
      def gloo_file?( name )
        return @mech.valid?( name )
      end

      #
      # Get the default file extention.
      #
      def file_ext
        return @mech.file_ext
      end

      #
      # Print out all object - persistance mappings.
      # This is a debugging tool.
      #
      def show_maps
        @maps.each do |o|
          puts " \t #{o.pn} \t #{o.obj.name}"
        end
      end

      private

      #
      # Resolve a name to an object for saving, reporting an error and
      # returning nil if it can't be found.
      #
      def resolve_for_save( name )
        obj = Gloo::Core::Pn.new( @engine, name ).resolve
        @engine.err( "#{OBJ_NOT_FOUND_ERR}#{name}" ) unless obj
        return obj
      end

      #
      # Walk up to the top-level declared object that contains obj --
      # its parent is the heap root, not another declared object.
      #
      def root_of( obj )
        o = obj
        o = o.parent until o.parent.nil? || o.parent.root?
        return o
      end

      #
      # Save a set of files as one batch so a multi-file namespace
      # round-trips: each file only rewrites the declarations its own
      # SourceDoc holds and leaves other files' declarations alone; a
      # brand-new object no file owns is written once, by the first file
      # in the batch to reach it.
      #
      def save_batch( files )
        claimed = {}.compare_by_identity
        files.each do |fs|
          fs.save( :others => owned_elsewhere( fs ), :claimed => claimed )
        end
      end

      #
      # Every heap object declared by some loaded file's SourceDoc
      # other than fs.
      #
      def owned_elsewhere( fs )
        owned = {}.compare_by_identity
        @maps.each do |other|
          next if other.equal?( fs )

          collect_owned( other.source_doc&.children, owned )
        end
        return owned
      end

      #
      # Recursively collect the objects declared by the given source
      # nodes into owned.
      #
      def collect_owned( nodes, owned )
        return unless nodes

        nodes.each do |node|
          next unless node.is_a?( Gloo::Persist::Source::ObjNode )

          owned[ node.obj ] = true if node.obj
          collect_owned( node.children, owned )
        end
      end

      #
      # Save to a path that's already mapped to some file. If that
      # mapping is for a different root, it's a real collision -- the
      # path belongs to something else.
      #
      def save_mapped( obj, mapped, pn )
        return @engine.err( "#{PATH_EXISTS_ERR}#{pn}" ) unless mapped.roots.include?( root_of( obj ) )

        @engine.event_manager.on_save obj
        save_batch( [ mapped ] )
      end

      #
      # Save an object's root fresh to a new path, and register the
      # resulting mapping.
      #
      def save_new( obj, pn )
        @engine.event_manager.on_save obj
        fs = Gloo::Persist::FileStorage.new( @engine, pn, root_of( obj ) )
        fs.save
        @maps << fs
      end

      #
      # Warn (without blocking) if reloading fs would discard changes
      # that haven't been saved -- any object whose value no longer
      # round-trips to what's on disk.
      #
      def warn_if_dirty( fs )
        saver = Gloo::Persist::FileSaver.new( @engine, fs.pn, fs.obj, fs.source_doc )
        @engine.log.warn "#{RELOAD_DIRTY_WARNING}#{fs.pn}" if saver.dirty?
      end

    end
  end
end
