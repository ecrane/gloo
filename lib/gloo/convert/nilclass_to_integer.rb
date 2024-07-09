# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Conversion tool:  Nil to Integer.
#
require 'chronic'

module Gloo
  module Convert
    class NilClassToInteger

      #
      # Convert a nil to a string.
      #
      def convert( value )
        return 0
      end

    end
  end
end
