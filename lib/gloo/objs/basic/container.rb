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
      MISSING_INDEX_MSG = 'Missing index!'.freeze

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
        return super + %w[count delete_children child_exists show_key_value_table
                          child_value_at child_path_at random_child_value random_child_path]
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

      #
      # Get the value of the child at the given 0-based index.
      #
      def msg_child_value_at
        child = child_at_param
        return child if child == false

        return put_child_value( child )
      end

      #
      # Get the path of the child at the given 0-based index.
      #
      def msg_child_path_at
        child = child_at_param
        return child if child == false

        return put_it( child.pn )
      end

      #
      # Get the value of a random child.
      #
      def msg_random_child_value
        child = random_child
        return child if child == false

        return put_child_value( child )
      end

      #
      # Get the path of a random child.
      #
      def msg_random_child_path
        child = random_child
        return child if child == false

        return put_it( child.pn )
      end

      # ---------------------------------------------------------------------
      #    Child Access Helpers
      # ---------------------------------------------------------------------

      #
      # Find the child at the index given as the message parameter.
      # Reports the problem, puts false into it, and returns false
      # if there is no index or no child at that index.
      #
      def child_at_param
        unless @params&.token_count&.positive?
          @engine.syntax_err MISSING_INDEX_MSG
          return put_it( false )
        end

        expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
        data = expr.evaluate
        index = Container.to_index( data )
        if index.nil?
          @engine.err "Index '#{data}' is not a number!"
          return put_it( false )
        end

        if index.negative? || index >= child_count
          @engine.err "Index #{index} is out of range (0 to #{child_count - 1})!"
          return put_it( false )
        end

        return children[ index ]
      end

      #
      # Get a whole number index from an evaluated parameter.
      # Returns nil if it isn't one.
      #
      def self.to_index( data )
        return data if data.is_a?( ::Integer )
        return data.strip.to_i if data.is_a?( ::String ) && data.strip.match?( /\A-?\d+\z/ )

        return nil
      end

      #
      # Pick a random child.
      # Reports the problem, puts false into it, and returns false
      # if the container is empty.
      #
      def random_child
        if child_count.zero?
          @engine.err "Container '#{pn}' is empty!"
          return put_it( false )
        end

        return children.sample
      end

      #
      # Put the value of the child into it.
      # A container child has no value of its own; use its path instead.
      #
      def put_child_value( child )
        child = Gloo::Objs::Alias.resolve_alias( @engine, child )
        if child.is_container?
          @engine.err "Child '#{child.pn}' is a container, not a value! Use its path instead."
          return put_it( false )
        end

        return put_it( child.value )
      end

      #
      # Put the value into it and return it.
      #
      def put_it( val )
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
            'show_key_value_table — Show a table with key (name) and values for all children in the container.',
            'child_exists ({name}) — Check to see if there is a child with the given name. A parameter is required. It will have a boolean.',
            'child_value_at ({index}) — Get the value of the child at position {index}. Positions are 0-based and in the order the children were added, so after split_list, index 0 is the child named 1. A parameter is required. It will have the value; an out-of-range or non-numeric index, or a child that is a container, is an error, and it will have false.',
            'child_path_at ({index}) — Get the path (from root) of the child at position {index}, 0-based. Works for any child, including a container; put it into an alias (put it into ptr*) to reach the child and its fields. A parameter is required. It will have the path; an out-of-range or non-numeric index is an error, and it will have false.',
            'random_child_value — Get the value of a randomly chosen child. It will have the value; an empty container, or picking a child that is a container, is an error, and it will have false.',
            'random_child_path — Get the path (from root) of a randomly chosen child. It will have the path; an empty container is an error, and it will have false.'
          ],
          :notes => 'The random_child messages pick with replacement: two ' \
            'calls can pick the same child. For distinct picks, pick a ' \
            'random index with an integer\'s randomize message, keep the ' \
            'indexes already used as children of another container, and ' \
            'check it with child_exists before using child_path_at.',
          :examples => <<~EXAMPLES.strip
            can [can] :
              data [can] :
                1 : one
                2 : two
                3 : three
              on_load [script] :
                tell can.data to show_key_value_table

            #
            # Reach a container child's fields through an alias.
            #
            books [can] :
              list [can] :
                a [can] :
                  title [string] : Walden
                b [can] :
                  title [string] : Emma
              ptr [alias] :
              on_load [script] :
                tell books.list to child_path_at (1)
                put it into books.ptr*
                show books.ptr.title
          EXAMPLES
        }
      end

    end
  end
end
