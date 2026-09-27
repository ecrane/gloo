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

      #
      # Is the value really a time? A blank value is no value. A clock
      # time out of range (eg. 25:99) is parsed, but rolls over.
      #
      def valid?( value, result )
        return true if value.blank?

        return !result.nil? && !StringToTime.clock_out_of_range?( value )
      end

      #
      # Describe the guess for a warning.
      #
      def describe( result )
        return result.strftime( Gloo::Objs::Time::DEFAULT_FORMAT )
      end

      #
      # Does the value have a clock time (h:mm or h:mm:ss) with an hour,
      # minute or second out of range?
      #
      def self.clock_out_of_range?( value )
        m = value.match( /(\d{1,2}):(\d{2})(?::(\d{2}))?/ )
        return false unless m

        return m[ 1 ].to_i > 24 || m[ 2 ].to_i > 59 || m[ 3 ].to_i > 59
      end

    end
  end
end
