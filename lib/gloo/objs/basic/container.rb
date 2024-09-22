# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that contains a collection of other objects.
#

module Gloo
  module Objs
    class Container < Gloo::Core::Obj

      KEYWORD = 'container'.freeze
      KEYWORD_SHORT = 'can'.freeze

      #
      # The name of the object type.
      #
      def self.typename
        return KEYWORD
      end

      #
      # The short name of the object type.
      #
      def self.short_typename
        return KEYWORD_SHORT
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[count delete_children child_exists show_key_value_table]
      end

      #
      # Count the number of children in the container.
      #
      def msg_count
        i = child_count
        @engine.heap.it.set_to i
        return i
      end

      #
      # Delete all children in the container.
      #
      def msg_delete_children
        self.delete_children
      end

      #
      # Show the given table data.
      #
      def msg_show_key_value_table
        data = self.children.map { |o| [ o.name, o.value ] }

        @engine.platform.table.show [], data
      end

      # 
      # Check to see if there is a child with the given name.
      # 
      def msg_child_exists
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
        end
        return unless data

        val = self.contains_child?( data )
        @engine.heap.it.set_to val
        return val
      end
    end
  end
end
