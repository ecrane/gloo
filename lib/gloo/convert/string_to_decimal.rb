# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Conversion tool:  String to Decimal.
#

module Gloo
  module Convert
    class StringToDecimal

      #
      # Convert the given string value to a decimal.
      #
      def convert( value )
        return value.to_f
      end

      #
      # Is the value really a decimal number, written the way a decimal
      # literal is (see LDecimal)? A blank value is no value (0.0).
      #
      def valid?( value, _result )
        return true if value.blank?

        return Gloo::Expr::LDecimal.number?( value )
      end

    end
  end
end
