# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A Time object (does not include a date).
#

module Gloo
  module Objs
    class Time < Gloo::Core::Obj

      KEYWORD = 'time'.freeze
      KEYWORD_SHORT = 'time'.freeze
      DEFAULT_FORMAT = '%I:%M:%S %P'.freeze

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
        if DtTools.is_dt_type? new_value
          self.value = new_value
        else
          self.value = @engine.converter.convert( new_value, 'Time', nil )
        end

        if DtTools.is_dt_type? self.value
          self.value = self.value.strftime( DEFAULT_FORMAT )
        end
      end

      #
      # Value for a SQL query.
      #
      def sql_value
        return nil if self.value.blank?
        
        return Chronic.parse( self.value )
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[now add sub]
      end

      #
      # Set to the current time.
      #
      def msg_now
        self.set_value( DateTime.now )
        @engine.heap.it.set_to self.value
      end

      #
      # Add the given modifier to the time.
      #
      def msg_add
        modifier = "1 hour"
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
          modifier = data
        end
        
        dt = Chronic.parse( self.value )
        new_value = DtTools.add( dt, modifier )
        self.set_value( new_value )
        @engine.heap.it.set_to self.value
      end

      #
      # Subtract the given modifier from the time.
      #
      def msg_sub
        modifier = "1 hour"
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
          modifier = data
        end

        dt = Chronic.parse( self.value )
        self.set_value( DtTools.sub( dt, modifier ) )
        @engine.heap.it.set_to self.value
      end
    end
  end
end
