# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Conversion tool:  Nil to Date.
#
require 'chronic'

module Gloo
  module Convert
    class NilClassToDate

      #
      # Convert a nil to a date.
      #
      def convert( value )
        return Chronic.parse( '' )
      end

    end
  end
end
