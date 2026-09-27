# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Addition operator.
#

module Gloo
  module Expr
    class OpPlus < Gloo::Core::Op

      SYMBOL = '+'.freeze
      # An alternate spelling that reads better when joining strings:
      # put first and ' ' and last into full_name
      ALT_SYMBOL = 'and'.freeze

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
