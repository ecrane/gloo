# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Conversion tool:  Nil to Time.
#
require 'chronic'

module Gloo
  module Convert
    class NilClassToTime

      #
      # Convert a nil to a time.
      #
      def convert( value )
        return Chronic.parse( '' )
      end

    end
  end
end
