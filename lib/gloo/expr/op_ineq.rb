# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2025 Eric Crane.  All rights reserved.
#
# Inequality operator.
#

module Gloo
  module Expr
    class OpIneq < Gloo::Core::Op

      SYMBOL = '!='.freeze

      #
      # Perform the operation and return the result.
      #
      def perform( left, right )
        return left != right.to_s if left.is_a? String

        return left != right.to_i if left.is_a? Integer

        return left != right.to_f if left.is_a? Numeric
        
        return false
      end

    end
  end
end
