# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2023 Eric Crane.  All rights reserved.
#
# Conversion tool:  String to Time.
#
require 'chronic'

module Gloo
  module Convert
    class StringToTime

      #
      # Convert the given string value to time.
      #
      def convert( value )
        return Chronic.parse( value )
      end

    end
  end
end
