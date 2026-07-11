# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2025 Eric Crane.  All rights reserved.
#
# Equality operator.
#

module Gloo
  module Expr
    class OpEq < Gloo::Core::Op

      SYMBOL = '='.freeze
      ALT_SYMBOL = '=='.freeze

      #
      # Perform the operation and return the result.
      #
      def perform( left, right )
        cmp = DtTools.compare_dt( left, right )
        return cmp == 0 unless cmp == :not_dt

        return left == right.to_s if left.is_a? String

        return left == right.to_i if left.is_a? Integer

        return left == right.to_f if left.is_a? Numeric

        if Gloo::Objs::Boolean.boolean?( left ) && Gloo::Objs::Boolean.boolean?( right )
          return left == right
        end

        return false
      end

    end
  end
end
