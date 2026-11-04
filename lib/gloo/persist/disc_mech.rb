# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# Disc based mechanism for files.
# Provides interaction between the persistence classes and the OS
# file and folder system.
# This class might be overridden elsewhere to provide other mechanism.
# For example, in gloo-web, there will be a db based mechanism.
#

module Gloo
  module Persist
    class DiscMech

      #
      # Set up a disc based file mechanism.
      #
      def initialize( engine )
        @engine = engine
        @log = @engine.log
      end

      #
      # Get the default file extention.
      #
      def file_ext
        return '.gloo'
      end

      #
      # Get all the gloo files in the folder (partial path). The folder
      # can end with the start of a file name, as a prefix (folder/a).
      # A relative folder is looked for in each of the given folders in
      # turn (see default_folders); the first that has matching files
      # wins.
      #
      def get_all_files_in( folder, folders = nil )
        return Dir.glob( "#{absolute_folder( folder )}*.gloo" ) if absolute?( folder )

        ( folders || default_folders ).each do |base|
          files = Dir.glob( "#{File.join( base, folder )}*.gloo" )
          return files.map { |f| File.expand_path( f ) } unless files.empty?
        end
        return []
      end

      #
      # An absolute or ~ folder, with ~ expanded.
      #
      def absolute_folder( folder )
        return folder.sub( '~', Dir.home ) if folder.start_with?( '~' )

        return folder
      end

      #
      # Is the name a full path, or one starting with ~?
      #
      def absolute?( name )
        return name.start_with?( '~' ) || File.absolute_path?( name )
      end

      #
      # Where a relative name is looked for when no folders are given:
      # the project folder, then the gloo home.
      #
      def default_folders
        return [ @engine.settings.project_path, @engine.settings.user_root ]
      end

      # 
      # Check if a file exists.
      # 
      def exist?( file )
        File.exist?( file )
      end

      # 
      # Check to see if the file is valid.
      # 
      def valid?( file )
        return false unless file
        return false unless File.exist?( file )
        return false unless File.file?( file )
        return false unless file.end_with?( self.file_ext )

        return true
      end

      #
      # Expand a single file path. The .gloo extension is optional: it's
      # added when the name doesn't end with it.
      #
      # A full or ~ path is used as given. A relative name is looked for
      # in each of the given folders in turn (the load verb's order, see
      # PersistMan#search_folders). With no folders given (a file named
      # on the command line), it's tried as given, relative to the
      # working folder, and then in the project folder and gloo home.
      #
      def expand( name, folders = nil )
        full_name = name.end_with?( file_ext ) ? name : "#{name}#{file_ext}"
        return expand_in( full_name, folders ) if folders && !absolute?( name )

        # Try the name as given: a full path, or relative to the working
        # folder (eg. gloo hello_world.gloo).
        ext_path = File.expand_path( name )
        return [ ext_path ] if self.valid?( ext_path )

        # A full or ~ path without the extension.
        if absolute?( name )
          ext_path = File.expand_path( full_name )
          return [ ext_path ] if self.valid?( ext_path )
        end

        return expand_in( full_name, default_folders )
      end

      #
      # The file in the first of the folders that has it, as a one-item
      # list; nil if none does.
      #
      def expand_in( full_name, folders )
        folders.each do |base|
          pn = File.expand_path( File.join( base, full_name ) )
          return [ pn ] if self.valid?( pn )
        end
        return nil
      end

      #
      # Read in the contents of a single file, as UTF-8 whatever the
      # locale: a .gloo file is UTF-8 (under LANG=C, a plain read would
      # take every non-ASCII character as an invalid byte). Bytes that
      # aren't valid UTF-8 are kept as they are; the loader warns about
      # them.
      #
      def read( file )
        return File.binread( file ).force_encoding( Encoding::UTF_8 )
      end

      #
      # Resolve a path to save a new (not-yet-existing) file to, given
      # a name or relative path, with .gloo appended if missing. Unlike
      # expand, the file doesn't have to exist. A full path is used as
      # given and a ~ path is expanded. A relative name goes in the
      # given folder (the first place a load would look, see
      # PersistMan#save_folder), or the project folder if none is given.
      #
      def resolve_save_path( name, folder = nil )
        full_name = name.end_with?( file_ext ) ? name : "#{name}#{file_ext}"
        return File.expand_path( absolute_folder( full_name ) ) if absolute?( full_name )

        return File.expand_path( File.join( folder || @engine.settings.project_path, full_name ) )
      end

      #
      # Write data to the file, byte for byte (no conversion for the
      # locale).
      #
      def write( pn, data )
        File.binwrite( pn, data )
      end

    end
  end
end
