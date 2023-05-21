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
        return [ '+', '-', '*', '/' ].include?( token.strip )
      end

      #
      # Create the operator for the given token.
      #
      def self.create_op( token )
        return Gloo::Expr::OpMinus.new if token == '-'
        return Gloo::Expr::OpMult.new if token == '*'
        return Gloo::Expr::OpDiv.new if token == '/'
        return Gloo::Expr::OpPlus.new if token == '+'

        return default_op
      end

      #
      # Get the default operator (+).
      #
      def self.default_op
        return Gloo::Expr::OpPlus.new
      end

    end
  end
end
