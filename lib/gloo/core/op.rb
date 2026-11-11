# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An Operator; part of an expression.
# A static helper class.
#

module Gloo
  module Core
    class Op

      NOT_A_NUMBER_WARN = "'%s' is not a number; using 0.".freeze

      # The engine, for warnings; set by the expression before perform.
      attr_accessor :engine

      #
      # Is the token an operator?
      #
      def self.op?( token )
        return [ 
          Gloo::Expr::OpPlus::SYMBOL,
          Gloo::Expr::OpPlus::ALT_SYMBOL,
          Gloo::Expr::OpMinus::SYMBOL,
          Gloo::Expr::OpMult::SYMBOL,
          Gloo::Expr::OpDiv::SYMBOL,
          Gloo::Expr::OpEq::SYMBOL,
          Gloo::Expr::OpEq::ALT_SYMBOL,
          Gloo::Expr::OpIneq::SYMBOL,
          Gloo::Expr::OpGt::SYMBOL,
          Gloo::Expr::OpLt::SYMBOL,
          Gloo::Expr::OpGteq::SYMBOL,
          Gloo::Expr::OpLteq::SYMBOL
          ].include?( token.strip )
      end

      #
      # Create the operator for the given token.
      #
      def self.create_op( token )
        case token
          when Gloo::Expr::OpPlus::SYMBOL then Gloo::Expr::OpPlus.new
          when Gloo::Expr::OpPlus::ALT_SYMBOL then Gloo::Expr::OpPlus.new
          when Gloo::Expr::OpMinus::SYMBOL then Gloo::Expr::OpMinus.new
          when Gloo::Expr::OpMult::SYMBOL then Gloo::Expr::OpMult.new
          when Gloo::Expr::OpDiv::SYMBOL then Gloo::Expr::OpDiv.new
          when Gloo::Expr::OpEq::SYMBOL then return Gloo::Expr::OpEq.new
          when Gloo::Expr::OpEq::ALT_SYMBOL then return Gloo::Expr::OpEq.new
          when Gloo::Expr::OpIneq::SYMBOL then return Gloo::Expr::OpIneq.new
          when Gloo::Expr::OpGt::SYMBOL then return Gloo::Expr::OpGt.new
          when Gloo::Expr::OpLt::SYMBOL then return Gloo::Expr::OpLt.new
          when Gloo::Expr::OpGteq::SYMBOL then return Gloo::Expr::OpGteq.new
          when Gloo::Expr::OpLteq::SYMBOL then return Gloo::Expr::OpLteq.new
        else return default_op
        end
      end

      #
      # Get the default operator (+).
      #
      def self.default_op
        return Gloo::Expr::OpPlus.new
      end

      #
      # Promote two numbers to a common type, the one rule every
      # operator uses when both values are numbers.
      # An integer with an integer stays an integer; a decimal on
      # either side makes both decimals.
      # Returns [ left, right ], or nil unless both are numbers.
      #
      def promote( left, right )
        return nil unless left.is_a?( Numeric ) && right.is_a?( Numeric )
        return [ left, right ] if left.is_a?( Integer ) && right.is_a?( Integer )

        return [ left.to_f, right.to_f ]
      end

      #
      # Compare two strings in dictionary order, the rule the
      # ordering operators (< > <= >=) use for text with text.
      # Case is ignored first; only on a tie does a capital come
      # first, so 'apple' < 'Banana' < 'banana'.
      # Equal only when the strings are exactly the same, as with =.
      # Returns -1, 0 or 1, or nil unless both are strings.
      #
      def compare_text( left, right )
        return nil unless left.is_a?( String ) && right.is_a?( String )

        cmp = left.downcase <=> right.downcase
        return cmp unless cmp.zero?

        # Same letters; character codes put the capital first.
        return left <=> right
      end

      #
      # Compare two values, the rule every comparison operator uses:
      # number with number, numerically (after promotion); text with
      # text, in dictionary order; number with text, numerically if the
      # text is a number, otherwise as text.
      # Returns -1, 0 or 1, or nil for any other kinds of value.
      #
      def compare( left, right )
        if left.is_a?( Numeric ) && right.is_a?( String )
          right = text_to_number( right ) || right
          left = left.to_s if right.is_a?( String )
        elsif left.is_a?( String ) && right.is_a?( Numeric )
          left = text_to_number( left ) || left
          right = right.to_s if left.is_a?( String )
        end

        nums = promote( left, right )
        return nums[ 0 ] <=> nums[ 1 ] if nums

        return compare_text( left, right )
      end

      #
      # Get the two values as numbers for math (- * /), promoted.
      # Text is used as a number; text that isn't one is 0, with a
      # warning (blank text is 0 without one, as in an [int]).
      # Returns [ left, right ], or nil unless both are numbers then.
      #
      def math_numbers( left, right )
        return promote( text_as_number( left ), text_as_number( right ) )
      end

      #
      # The number written in the text (as a literal would be:
      # 5, -5, 2.50, .5), or nil if the text isn't a number.
      #
      def text_to_number( text )
        s = text.strip
        return s.to_i if Gloo::Expr::LInteger.integer?( s )
        return s.to_f if Gloo::Expr::LDecimal.decimal?( s )

        return nil
      end

      private

      #
      # Text as a number for math: the number it holds, or 0 (with a
      # warning unless blank). Anything that isn't text is unchanged.
      #
      def text_as_number( value )
        return value unless value.is_a?( String )

        num = text_to_number( value )
        return num if num
        return 0 if value.strip.empty?

        # Ops made outside an expression (eg. in a unit test) have no engine.
        @engine&.warn format( NOT_A_NUMBER_WARN, value )
        return 0
      end

    end
  end
end
