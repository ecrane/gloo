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
        return value.to_i
      end

    end
  end
end
