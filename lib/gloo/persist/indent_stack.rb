# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Tracks the current nesting level shared by the heap tree and the
# source tree as declaration lines are processed, pushing and popping
# both stacks in lockstep so their nesting always matches -- an object
# only becomes a parent once a deeper line actually follows it.
#

module Gloo
  module Persist
    class IndentStack

      attr_reader :tabs

      #
      # Set up a stack rooted at the given heap object and source node.
      #
      def initialize( root_obj, root_node )
        @tabs = 0
        @parent_stack = [ root_obj ]
        @node_stack = [ root_node ]
      end

      #
      # The heap object new children should be created under.
      #
      def parent
        return @parent_stack.last
      end

      #
      # The source node new declarations/trivia should be appended to.
      #
      def node
        return @node_stack.last
      end

      #
      # Move the stacks to the right depth for a line at the given
      # indentation, then -- if it turned out to be deeper than the
      # previous line -- push the previous line's object/node as the
      # new parent. last_obj/last_node are whatever was created for the
      # previous declaration line.
      #
      def place( line_tabs, last_obj, last_node )
        indent = indent_delta( line_tabs )
        if indent.positive?
          @parent_stack.push last_obj
          @node_stack.push last_node
        elsif indent.negative?
          indent.abs.times do
            @parent_stack.pop
            @node_stack.pop
          end
        end
      end

      private

      #
      # Update @tabs for the new line and return the signed change in
      # nesting depth: positive if it's more indented than the last
      # line placed, negative if less, zero if the same.
      #
      def indent_delta( line_tabs )
        if line_tabs > @tabs
          # TODO:  What if indent is more than one more level?
          @tabs = line_tabs
          return 1
        elsif line_tabs < @tabs
          diff = @tabs - line_tabs
          @tabs -= diff
          return -diff
        end

        return 0
      end

    end
  end
end
