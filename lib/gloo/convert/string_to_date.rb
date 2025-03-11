# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2023 Eric Crane.  All rights reserved.
#
# Conversion tool:  String to Date.
#
require 'chronic'

module Gloo
  module Convert
    class StringToDate

      #
      # Convert the given string value to date.
      #
      def convert( value )
        # 
        # TODO: figure out why I needed to add this.
        # The trailing ' am' was causing Chronic to fail.
        # 
        value = value[0..-3] if value.end_with?( ' am' )
        return Chronic.parse( value )
      end

    end
  end
end
