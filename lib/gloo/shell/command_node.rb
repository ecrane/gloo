# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# A node in a shell's command tree.
# Ported from gloo-cli's CommandNode, namespace only.
#

module Gloo
  module Shell
    class CommandNode

      attr_reader :name, :description, :method, :obj

      #
      # Initialize a command node.
      # Children are supplied lazily via a block, evaluated
      # with the shell's Context whenever they're needed.
      #
      def initialize( name, description: '', method: nil, obj: nil, &children_block )
        @name = name
        @description = description
        @method = method
        @obj = obj
        @children_block = children_block
      end

      #
      # Get this node's children, given the current shell context.
      # Returns an empty array for leaf nodes.
      #
      def children( context )
        return [] unless @children_block

        @children_block.call( context )
      end

    end
  end
end
