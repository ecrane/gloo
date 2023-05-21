# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Addition operator.
#

module Gloo
  module Expr
    class OpPlus < Gloo::Core::Op

      #
      # Perform the operation and return the result.
      #
      def perform( left, right )
        return left + right.to_s if left.is_a? String

        return left + right.to_i if left.is_a? Integer

        return left + right.to_f if left.is_a? Numeric
      end

    end
  end
end
