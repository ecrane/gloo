# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An Operator; part of an expression.
# A static helper class.
#

module Gloo
  module Core
    class Op

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

    end
  end
end
