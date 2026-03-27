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
      WILD = '*'.freeze

      
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
        folder = @iterator_obj.in_value
        return unless folder

        unless Dir.exist?( folder )
          # This is not an error because the path might include a wildcard.
          @engine.log.info "Folder does not exist: #{folder}"
        end

        Dir.glob( "#{folder}#{wildcard}" ).each do |f|
          set_file f
          @iterator_obj.run_do
        end
      end

      # 
      # Get the wildcard for the glob.
      # 
      def wildcard
        o = @iterator_obj.find_child EXT
        return WILD unless o

        return "#{WILD}.#{o.value}"
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
