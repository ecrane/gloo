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
      #
      def get_all_files_in( folder )
        dir = folder_for_files( folder )
        return Dir.glob( "#{dir}*.gloo" )
      end

      #
      # Where to look for a folder of files: an absolute or ~ folder as
      # given (~ expanded), anything else in the project folder, or if it
      # isn't there, in the gloo home.
      #
      def folder_for_files( folder )
        return folder.sub( '~', Dir.home ) if folder.start_with?( '~' )
        return folder if File.absolute_path?( folder )

        dir = File.join( @engine.settings.project_path, folder )
        return dir if Dir.exist?( dir )

        @log.debug "Folder does not exist in project: #{folder}"
        dir = File.join( @engine.settings.user_root, folder )
        @log.debug "Looking in gloo home? found == #{Dir.exist?( dir )}"
        return dir
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
      # added when the name doesn't end with it, for a full or ~ path
      # and for a name in the project or gloo home.
      #
      def expand( name )
        # Try the name as given: a full path, or relative to the working
        # folder (eg. gloo hello_world.gloo).
        ext_path = File.expand_path( name )
        return [ ext_path ] if self.valid?( ext_path )

        full_name = name.end_with?( file_ext ) ? name : "#{name}#{file_ext}"

        # A full or ~ path without the extension.
        if name.start_with?( '~' ) || File.absolute_path?( name )
          ext_path = File.expand_path( full_name )
          return [ ext_path ] if self.valid?( ext_path )
        end

        # Try in projects
        pn = File.join( @engine.settings.project_path, full_name )
        return [ pn ] if self.valid?( pn )

        # Try in user root
        pn = File.join( @engine.settings.user_root, full_name )
        return [ pn ] if self.valid?( pn )

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
      # a name or relative path -- same convention as expand (relative
      # to the project root, .gloo appended if missing), but without
      # requiring the file to already exist.
      #
      def resolve_save_path( name )
        full_name = name.end_with?( file_ext ) ? name : "#{name}#{file_ext}"
        return full_name if full_name.start_with?( '/' )

        return File.join( @engine.settings.project_path, full_name )
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
