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
      # Get all the gloo files in the folder (partial path).
      #
      def get_all_files_in( folder )
        pns = []
        dir = File.join( @engine.settings.project_path, folder )

        unless Dir.exist?( dir )
          @log.debug "Folder does not exist in project: #{folder}"
          dir = File.join( @engine.settings.user_root, folder )
          @log.debug "Looking in gloo home? found == #{Dir.exist?( dir )}"
        end

        Dir.glob( "#{dir}*.gloo" ).each do |f|
          pns << f
        end
        return pns
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
      # Expand a single file path.
      # 
      def expand( name )
        # Try full path
        ext_path = File.expand_path( name )
        return [ ext_path ] if self.valid?( ext_path )

        # Try in user root, projects
        full_name = "#{name}#{file_ext}"
        pn = File.join( @engine.settings.project_path, full_name )
        return [ pn ] if self.valid?( pn )
        
        # Try in user root
        pn = File.join( @engine.settings.user_root, full_name )
        return [ pn ] if self.valid?( pn )
        
        return nil
      end

      #
      # Read in the contents of a single file.
      #
      def read( file )
        return File.read( file )
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
      # Write data to the file.
      # 
      def write( pn, data )
        File.write( pn, data )
      end

    end
  end
end
