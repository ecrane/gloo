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

      #
      # Constructor for the persistence manager.
      #
      def initialize( engine )
        @engine = engine
        @maps = []
        @mech = @engine.platform.get_file_mech( @engine )
      end

      #
      # Save one object to the file.
      #
      def save( name = '' )
        name.blank? ? save_all : save_one( name )
      end

      #
      # Save one object to the file.
      #
      def save_all
        @maps.each( &:save )
      end

      #
      # Save one object to the file.
      #
      def save_one( name )
        ref = Gloo::Core::Pn.new( @engine, name )
        obj = ref.resolve

        # Send an on_save event
        @engine.event_manager.on_save obj

        fs = find_file_storage( obj )
        fs.save
      end

      #
      # Load the object from the file.
      #
      def load( name )
        pns = get_full_path_names name
        return unless pns

        pns.each do |pn|
          @engine.log.debug "Load file(s) at: #{pn}"
          fs = Gloo::Persist::FileStorage.new( @engine, pn )
          fs.load
          @maps << fs
          @engine.event_manager.on_load fs.obj
        end
      end

      # 
      # Unload all loaded objects.
      # The engine  is reset to a clean state.
      # 
      def unload_all
        objs = self.maps.map { |fs| fs.obj }
        objs.each { |o| o.msg_unload }
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
        @maps.each_with_index do |o, i|
          if o.obj.pn === obj.pn
            @maps.delete_at( i )
            return
          end
        end
      end

      # 
      # Reload all objects.
      # First send a message to each object to let it know it is being reloaded.
      # Then let the engine restart to reload the files.
      # 
      def reload_all
        return unless @maps
        
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

    end
  end
end
