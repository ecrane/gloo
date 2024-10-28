# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Iterate over each word in a string.
# 

module Gloo
  module Objs
    class EachWord

      WORD = 'word'.freeze

      
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
        return true if iterator_obj.find_child WORD

        return false
      end


      # ---------------------------------------------------------------------
      #    Iterate
      # ---------------------------------------------------------------------

      #
      # Run for each word.
      #
      def run
        str = @iterator_obj.in_value
        return unless str

        str.split( ' ' ).each do |word|
          set_word word
          @iterator_obj.run_do
        end
      end

      #
      # Set the value of the word.
      #
      def set_word( word )
        o = @iterator_obj.find_child WORD
        return unless o

        o.set_value word
      end

    end
  end
end
