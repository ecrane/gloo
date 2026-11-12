# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# An object with a decimal value.
#

module Gloo
  module Objs
    class Decimal < Gloo::Core::Obj

      KEYWORD = 'decimal'.freeze
      KEYWORD_SHORT = 'num'.freeze

      # A fixed-point spec in a format string, eg. %.2f or %8.2f; the
      # precision (digits after the point) is captured, if given.
      FIXED_SPEC = /%[-+ 0#]*\d*(?:\.(\d+))?[fF]/
      # sprintf's precision for %f when none is given.
      DEFAULT_PRECISION = 6

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
        if new_value.nil?
          self.value = 0.0
          return
        end

        unless new_value.is_a? Numeric
          self.value = @engine.converter.convert( new_value, 'Decimal', 0.0 )
          return
        end

        self.value = new_value.to_f
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[round format]
      end

      #
      # Round the value to a whole value.
      # If a parameter is included in the message,
      # round to the precision given.
      #
      def msg_round
        data = 0
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate.to_i
        end

        i = self.value.round( data )
        set_value i
        @engine.heap.it.set_to i
        return i
      end

      #
      # Format the decimal.
      # With no parameter, adds comma separators to the whole part
      # (Ex: 1000.5 -> 1,000.5).
      # With a parameter, uses it as a sprintf-style format string (Ex: '%.2f').
      #
      # @param format [String] The sprintf-style format to use.
      #
      def msg_format
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          fmt = expr.evaluate
          formatted = format( fmt, rounded_for( fmt ) )
        else
          whole, frac = value.to_s.split( '.' )
          grouped = whole.reverse.scan( /.{1,3}/ ).join( ',' ).reverse
          formatted = frac ? "#{grouped}.#{frac}" : grouped
        end
        @engine.heap.it.set_to formatted
      end

      #
      # The value to format: for a fixed-point spec (%.2f), rounded to
      # its precision first, the way round does (halves away from zero),
      # so format and round always agree. sprintf alone works on the
      # binary value, and gives '%.2f' of 1.005 as 1.00. Other specs
      # (%e, %d, ...) get the value as it is.
      #
      def rounded_for( fmt )
        spec = FIXED_SPEC.match( fmt.to_s )
        return value unless spec

        precision = spec[ 1 ] ? spec[ 1 ].to_i : DEFAULT_PRECISION
        return value.round( precision )
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
          :description => 'A decimal (numeric) value.',
          :messages => [
            'round ({precision}) — Round to the nearest whole value. If ' \
              'an optional parameter is included, round to the precision specified. ' \
              'A half rounds away from zero: 2.5 -> 3, -2.5 -> -3, and 2.675 to 2 places -> 2.68.',
            'format ({fmt}) — With no parameter, adds comma separators to the whole part (e.g. 1000.5 -> 1,000.5). With a parameter, uses it as a sprintf-style format string (e.g. \'%.2f\'); for a fixed-point spec like %.2f the value is rounded first, as round does, so the two always agree (1.005 -> 1.01). It will have the formatted string.'
          ],
          :notes => 'A value that isn\'t a number (eg. \'x\' or \'1,5\') is used as a best guess, with a warning: "\'1,5\' is not a decimal number; using 1.0." A blank value is 0.0.',
          :examples => <<~EXAMPLES.strip
            d [can] :
              x [decimal] : 100
              on_load [script] :
                show d.x
                put d.x / 3 into d.x
                show d.x
                tell d.x to round (1)
                show d.x
          EXAMPLES
        }
      end

    end
  end
end
