# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# An object with a decimal value.
#

module Gloo
  module Objs
    class Decimal < Gloo::Core::Obj

      KEYWORD = 'decimal'.freeze
      KEYWORD_SHORT = 'num'.freeze

      #
      # The name of the object type.
      #
      def self.typename
        return KEYWORD
      end

      #
      # The short name of the object type.
      #
      def self.short_typename
        return KEYWORD_SHORT
      end

      #
      # Set the value with any necessary type conversions.
      #
      def set_value( new_value )
        if new_value.nil?
          self.value = 0.0
          return
        end

        unless new_value.is_a? Numeric
          self.value = @engine.converter.convert( new_value, 'Decimal', 0.0 )
          return
        end

        self.value = new_value.to_f
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[round]
      end

      #
      # Round the value to a whole value.
      # If a parameter is included in the message,
      # round to the precision given.
      #
      def msg_round
        data = 0
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate.to_i
        end

        i = self.value.round( data )
        set_value i
        @engine.heap.it.set_to i
        return i
      end

    end
  end
end
