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

      #
      # Is the value really a date and time? A blank value is no value.
      #
      def valid?( value, result )
        return true if value.blank?

        return !result.nil? && !StringToTime.clock_out_of_range?( value )
      end

      #
      # Describe the guess for a warning.
      #
      def describe( result )
        return result.strftime( Gloo::Objs::DateTime::DEFAULT_FORMAT )
      end

    end
  end
end
