# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Iterate over each child in an object container.
# 

module Gloo
  module Objs
    class EachChild

      CHILD = 'child'.freeze
      IN = 'IN'.freeze
      
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
        return true if iterator_obj.find_child CHILD

        return false
      end


      # ---------------------------------------------------------------------
      #    Iterate
      # ---------------------------------------------------------------------

      #
      # Run for each child.
      #
      def run
        o = @iterator_obj.find_child IN
        return unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        o.children.each do |child|
          set_child child
          @iterator_obj.run_do
        end
      end

      #
      # Set the child alias.
      #
      def set_child( obj )
        o = @iterator_obj.find_child CHILD
        return unless o

        o.set_value obj.pn
      end

    end
  end
end
