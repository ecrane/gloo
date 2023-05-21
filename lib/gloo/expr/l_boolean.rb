# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An Expression that can be evaluated.
#

module Gloo
  module Expr
    class LBoolean < Gloo::Core::Literal

      #
      # Is the given token a boolean?
      #
      def self.boolean?( token )
        return Gloo::Objs::Boolean.boolean? token
      end

      #
      # Set the value, converting to an boolean.
      #
      def set_value( value )
        @value = Gloo::Objs::Boolean.coerse_to_bool value
      end

      #
      # Get string representation
      #
      def to_s
        return 'false' unless @value

        return @value.to_s
      end

    end
  end
end
