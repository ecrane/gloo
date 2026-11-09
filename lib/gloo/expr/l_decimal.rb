# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A literal decimal value.
#

module Gloo
  module Expr
    class LDecimal < Gloo::Core::Literal

      # A decimal as written: an optional sign; digits with an optional
      # fraction, or just a fraction (.5); an optional exponent (1.0e3,
      # 2e-5). Not 5. (a path start, like 'list.'), and not 1_000 or
      # 0x1A. Plain digits match the pattern too, but they're an integer
      # (see decimal?).
      PATTERN = /\A[-+]?(\d+(\.\d+)?|\.\d+)([eE][-+]?\d+)?\z/

      #
      # Is the given token a decimal: a number with a fraction or an
      # exponent? A plain integer isn't (see LInteger).
      #
      def self.decimal?( token )
        return true if token.is_a? Numeric

        s = token.strip
        return PATTERN.match?( s ) && !LInteger.integer?( s )
      end

      #
      # Is the given text a number a decimal can hold: a decimal or an
      # integer, as written in a literal?
      #
      def self.number?( text )
        return decimal?( text ) || LInteger.integer?( text )
      end

      #
      # Set the value, converting to a decimal.
      #
      def set_value( value )
        value = value.to_s if value.is_a? Numeric

        @value = value.to_f
      end

      #
      # Get string representation
      #
      def to_s
        return self.value.to_s
      end

    end
  end
end
