# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Subtraction operator.
#

module Gloo
  module Expr
    class OpMinus < Gloo::Core::Op

      SYMBOL = '-'.freeze

      #
      # Perform the operation and return the result.
      #
      def perform( left, right )
        # Numbers, and text used as a number: promote, then work them out.
        nums = math_numbers( left, right )
        return nums[ 0 ] - nums[ 1 ] if nums

        return left - right.to_i if left.is_a? Integer

        return left - right.to_f if left.is_a? Numeric
      end

    end
  end
end
