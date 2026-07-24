# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object with an integer value.
#

module Gloo
  module Objs
    class Integer < Gloo::Core::Obj

      KEYWORD = 'integer'.freeze
      KEYWORD_SHORT = 'int'.freeze
      DEFAULT_RANDOM_RANGE = 100

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
        unless new_value.is_a? Numeric
          self.value = @engine.converter.convert( new_value, 'Integer', 0 )
          return
        end

        self.value = new_value.to_i
      end

      # 
      # Value for a SQL query.
      # 
      def sql_value
        return nil if self.value.blank?
        
        return self.value
      end


      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[inc dec randomize format]
      end

      #
      # Increment the integer
      #
      def msg_inc
        i = value + 1
        set_value i
        @engine.heap.it.set_to i
        return i
      end

      #
      # Decrement the integer
      #
      def msg_dec
        i = value - 1
        set_value i
        @engine.heap.it.set_to i
        return i
      end

      # 
      # Set the value to a random number.
      # The range is 0 to DEFAULT_RANDOM_RANGE (not including the range).
      # To model a 6-sided die, 
      # set range to 6 and add 1 to the result.
      # 
      def msg_randomize
        range = DEFAULT_RANDOM_RANGE

        # Check for a range.
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          range = expr.evaluate
        end

        rand_value = rand( range )
        set_value rand_value
        @engine.heap.it.set_to rand_value
        return rand_value
      end

      #
      # Format the integer.
      # With no parameter, adds comma separators (Ex: 1000 -> 1,000).
      # With a parameter, uses it as a sprintf-style format string (Ex: '%05d').
      #
      # @param format [String] The sprintf-style format to use.
      #
      def msg_format
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          fmt = expr.evaluate
          formatted = format( fmt, value )
        else
          formatted = value.to_s.reverse.scan( /.{1,3}/ ).join( ',' ).reverse
        end
        @engine.heap.it.set_to formatted
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
          :description => 'An integer (numeric) value.',
          :messages => [
            'inc — Increment the integer value by 1.',
            'dec — Decrement the integer value by 1.',
            'randomize ({max}) — Set the value of the integer to a random ' \
              'number. By default the range is 0..99 inclusive. Use an ' \
              'optional parameter to set the maximum of the range; the ' \
              'range always starts at 0. To model a 6-sided die, set the ' \
              'range to 6 and add 1 to the result.',
            'format ({fmt}) — With no parameter, adds comma separators (e.g. 1000 -> 1,000). With a parameter, uses it as a sprintf-style format string (e.g. \'%05d\'). It will have the formatted string.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Integer object.
            #

            i [can] :

              #
              # The integer value.
              #
              x [integer] : 0

              #
              # Do some basic tests with it
              #
              on_load [script] :
                show i.x
                tell i.x to inc
                show i.x
                put i.x * 10 into i.x
                show i.x

                # Show a random number
                tell ^.x to randomize
                show 'Random number (up to 100 by default): ' + ^.x

                tell ^.x to randomize(6)
                tell ^.x to inc
                show '6-sided dice: ' + ^.x

              # An uninitialized integer.
              y [integer] :
          EXAMPLES
        }
      end

    end
  end
end
