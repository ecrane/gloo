# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Conversion tool:  Nil to DateTime.
#
require 'chronic'

module Gloo
  module Convert
    class NilClassToDateTime

      #
      # Convert a nil to a datetime.
      #
      def convert( value )
        return Chronic.parse( '' )
      end

    end
  end
end
