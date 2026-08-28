# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Create an object, optionally of a type.
#

module Gloo
  module Verbs
    class Create < Gloo::Core::Verb

      KEYWORD = 'create'.freeze
      KEYWORD_SHORT = '`'.freeze
      AS = 'as'.freeze
      VAL = ':'.freeze
      NO_NAME_ERR = 'Object name is missing!'.freeze

      #
      # Run the verb.
      #
      def run
        name = @tokens.second
        type = @tokens.after_token( AS )
        value = @tokens.after_token( VAL )

        unless name
          @engine.err NO_NAME_ERR
          return
        end
        create name, type, value
      end

      #
      # Get the Verb's keyword.
      #
      def self.keyword
        return KEYWORD
      end

      #
      # Get the Verb's keyword shortcut.
      #
      def self.keyword_shortcut
        return KEYWORD_SHORT
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Create an object with given name of given type with
      # the given initial value.
      #
      def create( name, type, value )
        if Gloo::Expr::LString.string?( value )
          value = Gloo::Expr::LString.strip_quotes( value )
        end

        # Check to see if this is an alias
        pn = Gloo::Core::Pn.new( @engine, name )
        obj = pn.resolve if pn
        name = obj.value if obj&.is_alias?

        obj = @engine.factory.create( { name: name, type: type, value: value } )

        obj.add_default_children if obj&.add_children_on_create?
        @engine.heap.it.set_to value
      end

      # ---------------------------------------------------------------------
      #    Verb Documentation
      # ---------------------------------------------------------------------

      #
      # Get the verb's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Create a new object of given type with given ' \
            'value. Both type and value are optional when creating an object.',
          :syntax => [ 'create {new.object.path} as {type} : {value}' ],
          :parameters => [
            '{new.object.path} — The path and name of the new object.',
            '{type} — The type of the new object. Optional; if not provided the object will be untyped.',
            "{value} — The initial value for the new object. Optional; if not provided the object will have the default value for the type."
          ],
          :result => "If nothing exists at the path, a new object is " \
            "created with the given (or type-default) value and added " \
            "to the object tree, and it is set to that value. If an " \
            "object already exists at the path it is left unchanged — " \
            "the type and value given here are ignored — and it is set " \
            "to the existing object's current value.",
          :errors => [
            "#{NO_NAME_ERR} — The name of the object was not specified and the object cannot be created.",
            'Could not create object. Bad path: {name} — The parent container named in the path does not exist. The path is root-relative and every container above the new object must already exist.'
          ],
          :examples => <<~EXAMPLES.strip
            # Basic examples of creating an object from the gloo shell:
            > create x as integer : 1
            > create s : "abc"
            > create t

            # Example of creating an object with an alias:
            a [can] :
              ln [alias] : x

              on_load [script] :
                create a.ln* as string
                put 'test' into x
                show a.ln
          EXAMPLES
        }
      end

    end
  end
end
