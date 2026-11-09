# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An Expression that can be evaluated.
#

module Gloo
  module Expr
    class LInteger < Gloo::Core::Literal

      # An integer as written: an optional sign, then digits. Leading
      # zeros are fine (007 is 7, never octal).
      PATTERN = /\A[-+]?\d+\z/

      #
      # Is the given token an integer?
      #
      def self.integer?( token )
        return true if token.is_a? Integer

        return PATTERN.match?( token.strip )
      end

      #
      # Set the value, converting to an integer.
      #
      def set_value( value )
        @value = value.to_i
      end

      #
      # Get string representation
      #
      def to_s
        return self.value.to_s
      end

    end
  end
end
