# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object with a boolean value.
#

module Gloo
  module Objs
    class Boolean < Gloo::Core::Obj

      KEYWORD = 'boolean'.freeze
      KEYWORD_SHORT = 'bool'.freeze
      TRUE = 'true'.freeze
      FALSE = 'false'.freeze
      BOOLEAN_STRINGS = [ TRUE, FALSE, 't', 'f' ].freeze

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
        self.value = Gloo::Objs::Boolean.coerse_to_bool( new_value )
        return unless Gloo::Objs::Boolean.bad_value?( new_value )

        @engine.warn "'#{new_value}' is not true or false; using #{self.value}."
      end

      #
      # Is the value a string that isn't a boolean? A blank value is
      # no value (false).
      #
      def self.bad_value?( new_value )
        return false unless new_value.is_a?( ::String )
        return false if new_value.strip.empty?

        return !BOOLEAN_STRINGS.include?( new_value.strip.downcase )
      end

      #
      # Coerse the new value to a boolean value.
      #
      def self.coerse_to_bool( new_value )
        return false if new_value.nil?

        # I should be able to use this:
        # if new_value.kind_of?( String )
        # but it doesn't work.  I don't know why.
        if new_value.class.name == 'String'
          return true if new_value.strip.downcase == TRUE
          return false if new_value.strip.downcase == FALSE
          return true if new_value.strip.downcase == 't'
          return false if new_value.strip.downcase == 'f'
        elsif new_value.class.name == 'Integer'
          return new_value.zero? ? false : true
        end

        return new_value == true
      end

      #
      # Is the given token a boolean?
      #
      def self.boolean?( token )
        return true if token == true
        return true if token == false

        if token.class.name == 'String'
          return true if token.strip.downcase == TRUE
          return true if token.strip.downcase == FALSE
        end
        return false
      end

      #
      # Get the value for display purposes.
      #
      def value_display
        return value ? TRUE : FALSE
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[not true false]
      end

      #
      # Set the value to the opposite of what it is.
      #
      def msg_not
        v = !value
        set_value v
        @engine.heap.it.set_to v
        return v
      end

      #
      # Set the value to true.
      #
      def msg_true
        set_value true
        @engine.heap.it.set_to true
        return true
      end

      #
      # Set the value to false.
      #
      def msg_false
        set_value false
        @engine.heap.it.set_to false
        return false
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
          :description => 'A boolean value. Value will be either true or false.',
          :messages => [
            'not — Set the boolean to the opposite of what it is now.',
            'true — Set the boolean to true.',
            'false — Set the boolean to false.'
          ],
          :notes => 'Recognized values are true, false, t and f (in any case), and integers (0 is false). Any other string is false, with a warning: "\'maybe\' is not true or false; using false." A blank value is false.',
          :examples => <<~EXAMPLES.strip
            b [can] :
              flag [boolean] : true
              on_load [script] :
                show b.flag
                put false into b.flag
                show b.flag
                tell b.flag to not
                show b.flag
          EXAMPLES
        }
      end

    end
  end
end
