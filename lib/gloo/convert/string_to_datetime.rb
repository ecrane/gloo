# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Conversion tool:  String to Date Time.
#
require 'chronic'

module Gloo
  module Convert
    class StringToDateTime

      #
      # Convert the given string value to a date and time.
      #
      def convert( value )
        return Chronic.parse( value )
      end

    end
  end
end
