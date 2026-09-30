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
      BAD_NAME_CHARS = /[()"']/.freeze
      BAD_NAME_ERR = "'%s' isn't a name! To create an object at a " \
        'computed path, put the path into an alias, then create ' \
        'the alias: create slot* as string.'.freeze

      #
      # Run the verb.
      #
      def run
        name = @tokens.second
        type = @tokens.after_token( AS )
        value = @tokens.after_token( VAL )

        unless name
          @engine.syntax_err NO_NAME_ERR
          return @engine.heap.it.set_to( false )
        end
        return @engine.heap.it.set_to( false ) if bad_name?( name )
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
      # Is the name something create can't use? A name is taken as
      # written, so expression characters -- parentheses or quotes -- or
      # extra words between the name and 'as' / ':' mean the script was
      # trying to compute it. Report that and return true.
      #
      def bad_name?( name )
        after = @tokens.token_count > 2 ? @tokens.tokens[ 2 ] : nil
        return false unless name.match?( BAD_NAME_CHARS ) ||
                            !( after.nil? || after.downcase == AS || after.start_with?( VAL ) )

        written = @tokens.tokens[ 1..].take_while { |t| t.downcase != AS && !t.start_with?( VAL ) }
        @engine.syntax_err format( BAD_NAME_ERR, written.join( ' ' ) )
        return true
      end

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
        return if pn.it_target_err?( 'created',
          'it is reserved for the result of the last command, so use another name' )

        obj = pn.resolve if pn
        name = obj.value if obj&.is_alias?

        obj = @engine.factory.create( { name: name, type: type, value: value } )

        # Couldn't be created (already reported).
        return @engine.heap.it.set_to( false ) unless obj

        obj.add_default_children if obj.add_children_on_create?
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
            "Could not create '{path}': Object '{parent.path}' was not found. — The parent container named in the path does not exist. The path is root-relative and every container above the new object must already exist. Nothing is created, and it is false.",
            "#{format( BAD_NAME_ERR, '{name}' )} — The name has parentheses or quotes, or there are extra words between the name and as / : — create takes a name as written. Nothing is created, and it is false."
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
