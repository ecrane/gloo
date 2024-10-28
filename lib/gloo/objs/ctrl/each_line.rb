# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Iterate over each line in a text block.
# 

module Gloo
  module Objs
    class EachLine

      LINE = 'line'.freeze

      
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
        return true if iterator_obj.find_child LINE

        return false
      end


      # ---------------------------------------------------------------------
      #    Iterate
      # ---------------------------------------------------------------------

      #
      # Run for each line.
      #
      def run
        str = @iterator_obj.in_value
        return unless str

        str.each_line do |line|
          set_line line
          @iterator_obj.run_do
        end
      end

      #
      # Set the value of the word.
      #
      def set_line( line )
        o = @iterator_obj.find_child LINE
        return unless o

        o.set_value line
      end
      
    end
  end
end
