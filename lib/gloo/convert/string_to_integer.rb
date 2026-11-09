# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Conversion tool:  String to Integer.
#

module Gloo
  module Convert
    class StringToInteger

      #
      # Convert the given string value to an integer.
      #
      def convert( value )
        return 0 if value.blank?

        return value.to_i
      end

      #
      # Is the value really an integer, written the way an integer
      # literal is (see LInteger)? A blank value is no value (0).
      #
      def valid?( value, _result )
        return value.blank? || Gloo::Expr::LInteger.integer?( value )
      end

    end
  end
end
