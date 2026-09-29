# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Iterate over each directory in a folder.
# 

module Gloo
  module Objs
    class EachDir

      DIR = 'dir'.freeze
      RECURSIVE = 'recursive'.freeze
      
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
        return true if iterator_obj.find_child DIR

        return false
      end 


      # ---------------------------------------------------------------------
      #    Iterate
      # ---------------------------------------------------------------------

      #
      # Run for each directory.
      #
      def run
        folder = EachFile.expand_home( @iterator_obj.in_value )
        return unless folder

        unless Dir.exist?( folder )
          # A path with a wildcard is a pattern, not a folder.
          unless EachFile.wildcard?( folder )
            @engine.err Gloo::Core::NotFound.folder( folder )
            return
          end
        end

        Dir.glob( EachFile.pattern( folder, recursive? ) ).each do |f|
          next unless File.directory?( f )

          set_dir f
          @iterator_obj.run_do
        end
      end

      #
      # Walk the subfolders too?
      #
      def recursive?
        value = @iterator_obj.find_child_value RECURSIVE
        return Gloo::Objs::Boolean.coerse_to_bool( value )
      end

      #
      # Set the value of the dir.
      #
      def set_dir( f )
        o = @iterator_obj.find_child DIR
        return unless o

        o.set_value f
      end
      
    end
  end
end
