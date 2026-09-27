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

      # What place reports about a line's indentation, when it's
      # probably not what was meant (the loader warns about it).
      OVER_INDENTED = :over_indented
      MISALIGNED = :misaligned

      #
      # Set up a stack rooted at the given heap object and source node.
      #
      def initialize( root_obj, root_node )
        @levels = [ 0 ]
        @parent_stack = [ root_obj ]
        @node_stack = [ root_node ]
      end

      #
      # The indentation (in tabs) of the current nesting level.
      #
      def tabs
        return @levels.last
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
      # Each open nesting level remembers its own indentation, so a line
      # nests under the line above whenever it's deeper (by any amount),
      # and an outdent goes back to exactly the level it lines up with.
      #
      # Returns nil, or OVER_INDENTED if the line is more than one level
      # deeper than the line above, or MISALIGNED if an outdent doesn't
      # line up with any open level (it's nested under the closest one).
      #
      def place( line_tabs, last_obj, last_node )
        return indent( line_tabs, last_obj, last_node ) if line_tabs > tabs

        popped = nil
        while tabs > line_tabs
          @levels.pop
          popped = [ @parent_stack.pop, @node_stack.pop ]
        end
        return nil if tabs == line_tabs

        # Between two open levels: best guess, keep it under the
        # closest (deepest) one it's still inside of.
        push_level( line_tabs, *popped )
        return MISALIGNED
      end

      private

      #
      # A deeper line: the previous line's object/node becomes the
      # new parent.
      #
      def indent( line_tabs, last_obj, last_node )
        over = line_tabs > tabs + 1
        # last_obj is nil when the previous line failed to make an
        # object (eg. a type that can't be created) -- keep the
        # current parent rather than pushing nil.
        push_level( line_tabs, last_obj || parent, last_node || node )
        return over ? OVER_INDENTED : nil
      end

      #
      # Open a nesting level at the given indentation.
      #
      def push_level( line_tabs, obj, node )
        @levels.push line_tabs
        @parent_stack.push obj
        @node_stack.push node
      end

    end
  end
end
