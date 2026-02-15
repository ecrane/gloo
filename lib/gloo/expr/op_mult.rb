# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Multiplication operator.
#

module Gloo
  module Expr
    class OpMult < Gloo::Core::Op

      SYMBOL = '*'.freeze

      #
      # Perform the operation and return the result.
      #
      def perform( left, right )
        if ( left.is_a? Integer ) && ( right.is_a? Integer )
          return left * right
        end
        
        if (left.is_a? Numeric) && (right.is_a? Numeric)
          return left * right
        end

        return left * right.to_i if left.is_a? Integer

        return left * right.to_f if left.is_a? Numeric
      end

    end
  end
end
