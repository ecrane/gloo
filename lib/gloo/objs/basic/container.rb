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

      # ---------------------------------------------------------------------
      #    Object Documentation
      # ---------------------------------------------------------------------

      #
      # Get the object's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'A container of other objects. A container is ' \
            'similar to a folder in a file system. It can contain any ' \
            'number of objects including other containers. The ' \
            'container structure provides direct access to any object ' \
            'within it through the object.object.object path-name structure.',
          :children => [
            'None by default — but any container can have any number of objects added to it, at runtime.'
          ],
          :messages => [
            'count — Count the number of children objects in the container. The result is put in it.',
            'delete_children — Delete all children objects from the container.',
            'show_key_value_table — Show a table with key (name) and values for all children in the container.'
          ],
          :examples => <<~EXAMPLES.strip
            can [can] :
              data [can] :
                1 : one
                2 : two
                3 : three
              on_load [script] :
                tell can.data to show_key_value_table
          EXAMPLES
        }
      end

    end
  end
end
