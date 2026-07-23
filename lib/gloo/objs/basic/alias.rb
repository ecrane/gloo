# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# An Alias.
#

module Gloo
  module Objs
    class Alias < Gloo::Core::Obj

      KEYWORD = 'alias'.freeze
      KEYWORD_SHORT = 'ln'.freeze
      ALIAS_REFERENCE = '*'.freeze

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

      #
      # Set the value with any necessary type conversions.
      #
      def set_value( new_value )
        self.value = new_value.to_s
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[resolve]
      end

      #
      # Check to see if the referenced object exists.
      #
      def msg_resolve
        pn = Gloo::Core::Pn.new( @engine, self.value )
        s = pn.exists?
        @engine.heap.it.set_to s
        return s
      end

      # ---------------------------------------------------------------------
      #    Resolve
      # ---------------------------------------------------------------------

      #
      # Is the object an alias  If so, then resolve it.
      # The ref_name is the name used to refer to the object.
      # If it ends with the * then we won't resolve the alias since
      # we are trying to refer to the alias itself.
      #
      def self.resolve_alias( engine, obj, ref_name = nil )
        return nil unless obj
        return obj unless obj.type_display == Gloo::Objs::Alias.typename
        return obj if ref_name&.end_with?( ALIAS_REFERENCE )

        ln = Gloo::Core::Pn.new( engine, obj.value )
        return ln.resolve
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
          :description => 'A pointer to another object. Normal ' \
            'path-name references will refer to the aliased object. To ' \
            'refer to the alias itself, add an * at the end of the ' \
            'path-name — needed, for example, to set the value of the ' \
            'alias. The value of the alias is merely the path-name of ' \
            'the referenced object. Well constructed aliases will ' \
            'redirect to the referenced object through any number of ' \
            'steps, and relative references will also work in an alias.',
          :messages => [
            'resolve — Check to see if the object referenced exists. Sets it to true or false.'
          ],
          :notes => 'The alias also reflects (forwards) the messages of the object it points to.',
          :examples => <<~EXAMPLES.strip
            #
            # Alias object.
            #

            a [can] :
              s [string] : a string
              i [integer] : 13
              ln [alias] : a.s

              on_load [script] :
                show a.ln
                show a.ln*
                put 'a.i' into a.ln*
                put 7 into a.ln
                show a.ln
                run a.add

              #
              # Example of creating an object using an alias.
              #
              add [script] :
                put 'x' into a.ln*
                create a.ln* as string
                put 'test' into x
                show a.ln
          EXAMPLES
        }
      end

    end
  end
end
