# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object with an integer value.
#

module Gloo
  module Objs
    class Integer < Gloo::Core::Obj

      KEYWORD = 'integer'.freeze
      KEYWORD_SHORT = 'int'.freeze
      DEFAULT_RANDOM_RANGE = 100

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
        unless new_value.is_a? Numeric
          self.value = @engine.converter.convert( new_value, 'Integer', 0 )
          return
        end

        self.value = new_value.to_i
      end

      # 
      # Value for a SQL query.
      # 
      def sql_value
        return nil if self.value.blank?
        
        return self.value
      end


      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[inc dec randomize]
      end

      #
      # Increment the integer
      #
      def msg_inc
        i = value + 1
        set_value i
        @engine.heap.it.set_to i
        return i
      end

      #
      # Decrement the integer
      #
      def msg_dec
        i = value - 1
        set_value i
        @engine.heap.it.set_to i
        return i
      end

      # 
      # Set the value to a random number.
      # The range is 0 to DEFAULT_RANDOM_RANGE (not including the range).
      # To model a 6-sided die, 
      # set range to 6 and add 1 to the result.
      # 
      def msg_randomize
        range = DEFAULT_RANDOM_RANGE

        # Check for a range.
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          range = expr.evaluate
        end

        rand_value = rand( range )
        set_value rand_value
        @engine.heap.it.set_to rand_value
        return rand_value
      end

    end
  end
end
