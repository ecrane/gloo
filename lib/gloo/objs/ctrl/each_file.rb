# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Iterate over each file in a folder.
# 

module Gloo
  module Objs
    class EachFile

      FILE = 'file'.freeze
      EXT = 'ext'.freeze
      RECURSIVE = 'recursive'.freeze
      INCLUDE_DIRS = 'include_dirs'.freeze
      WILD = '*'.freeze
      RECURSE = '**'.freeze

      
      # ---------------------------------------------------------------------
      #    Create Iterator
      # ---------------------------------------------------------------------

      def initialize( engine, iterator_obj )
        @engine = engine
        @iterator_obj = iterator_obj
      end


      # ---------------------------------------------------------------------
      #    Check if this is the right iterator
      # ---------------------------------------------------------------------

      #
      # Use this iterator for each loop?
      #
      def self.use_for?( iterator_obj )
        return true if iterator_obj.find_child FILE

        return false
      end


      # ---------------------------------------------------------------------
      #    Iterate
      # ---------------------------------------------------------------------

      #
      # Run for each file.
      #
      def run
        folder = EachFile.expand_home( @iterator_obj.in_value )
        return unless folder

        unless Dir.exist?( folder )
          # This is not an error because the path might include a wildcard.
          @engine.log.info "Folder does not exist: #{folder}"
        end

        Dir.glob( EachFile.pattern( folder, recursive? ) ).each do |f|
          next unless include?( f )

          set_file f
          @iterator_obj.run_do
        end
      end

      #
      # Expand a leading ~ to the home folder.
      # Other paths are left as they are, so relative paths stay relative.
      #
      def self.expand_home( folder )
        return folder unless folder.is_a?( ::String ) && folder.start_with?( '~' )

        return File.expand_path( folder )
      end

      #
      # Get the glob pattern for everything in the folder, and
      # optionally everything in its subfolders.
      # The folder may itself include wildcards.
      #
      def self.pattern( folder, recursive )
        return File.join( folder, RECURSE, WILD ) if recursive

        return File.join( folder, WILD )
      end

      #
      # Does the folder path include glob wildcards?
      #
      def self.wildcard?( folder )
        return folder.to_s.match?( /[*?\[{]/ )
      end

      #
      # Should the loop run for this path?
      # Folders only when include_dirs is set; files only when they
      # match the extension, if there is one.
      #
      def include?( f )
        return include_dirs? if File.directory?( f )
        return false unless File.file?( f )

        return ext_match?( f )
      end

      #
      # Does the file have the extension we're looking for?
      # The match ignores case, so md matches .MD on every platform.
      #
      def ext_match?( f )
        ext = @iterator_obj.find_child_value EXT
        return true if ext.nil? || ext.to_s.strip.empty?

        ext = ext.to_s.strip.delete_prefix( '.' )
        return File.extname( f ).casecmp?( ".#{ext}" )
      end

      #
      # Walk the subfolders too?
      #
      def recursive?
        return child_true?( RECURSIVE )
      end

      #
      # List folders as well as files?
      #
      def include_dirs?
        return child_true?( INCLUDE_DIRS )
      end

      #
      # Is the named child present and true?
      #
      def child_true?( name )
        value = @iterator_obj.find_child_value name
        return Gloo::Objs::Boolean.coerse_to_bool( value )
      end

      #
      # Set the value of the word.
      #
      def set_file( f )
        o = @iterator_obj.find_child FILE
        return unless o

        o.set_value f
      end
      
    end
  end
end
