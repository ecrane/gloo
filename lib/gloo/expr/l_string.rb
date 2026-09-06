# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An Expression that can be evaluated.
#

module Gloo
  module Expr
    class LString < Gloo::Core::Literal

      #
      # Set the value, trimming opening and closing
      # quotations if necessary.
      #
      def set_value( value )
        @value = value
        return unless value

        @value = LString.strip_quotes( @value )
      end

      #
      # Is the given token a string?
      #
      def self.string?( token )
        return false unless token.is_a? String
        return true if token.start_with?( '"' )
        return true if token.start_with?( "'" )

        return false
      end

      #
      # Given a string with leading and trailing quotes, strip them
      # out. A quote of the other kind inside needs nothing done to it
      # ('{"x":1}' -> {"x":1}); an escaped quote of the same kind is
      # unescaped ("say \"hi\"" -> say "hi").
      #
      def self.strip_quotes( str )
        if str.start_with?( '"' )
          str = str[ 1..-1 ]
          str = str[ 0..-2 ] if str.end_with?( '"' )
          return str.gsub( '\\"', '"' )
        elsif str.start_with?( "'" )
          str = str[ 1..-1 ]
          str = str[ 0..-2 ] if str.end_with?( "'" )
          return str.gsub( "\\'", "'" )
        end

        return str
      end

      #
      # Get string representation
      #
      def to_s
        return self.value
      end

    end
  end
end
