# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2023 Eric Crane.  All rights reserved.
#
# Conversion tool:  String to Date.
#
require 'chronic'

module GlooLang
  module Convert
    class StringToDate

      #
      # Convert the given string value to date.
      #
      def convert( value )
        return Chronic.parse( value )
      end

    end
  end
end
