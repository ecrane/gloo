# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A Date and Time object.
#
require 'active_support/all'

module Gloo
  module Objs
    class Datetime < Gloo::Core::Obj

      KEYWORD = 'datetime'.freeze
      KEYWORD_SHORT = 'dt'.freeze
      DEFAULT_FORMAT = '%Y.%m.%d %I:%M:%S %P'.freeze

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
          self.value = @engine.converter.convert( new_value, 'DateTime', nil )
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
        return super + %w[now add sub is_today is_future
          is_past is_yesterday is_tomorrow is_this_week
          begin_day end_day begin_week end_week
          begin_month end_month begin_year end_year format]
      end

      #
      # Add the given modifier to the date.
      #
      def msg_add
        modifier = "1 day"
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
      # Subtract the given modifier from the date.
      #
      def msg_sub
        modifier = "1 day"
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
          modifier = data
        end

        dt = Chronic.parse( self.value )
        self.set_value( DtTools.sub( dt, modifier ) )
        @engine.heap.it.set_to self.value
      end

      #
      # Set the value to the beginning of the month.
      #
      def msg_begin_month
        dt = self.value.to_time.beginning_of_month
        self.set_value dt
        @engine.heap.it.set_to dt
      end

      #
      # Set the value to the end of the month.
      #
      def msg_end_month
        dt = self.value.to_time.end_of_month
        self.set_value dt
        @engine.heap.it.set_to dt
      end

      #
      # Set the value to the beginning of the year.
      #
      def msg_begin_year
        dt = self.value.to_time.beginning_of_year
        self.set_value dt
        @engine.heap.it.set_to dt
      end

      #
      # Set the value to the end of the year.
      #
      def msg_end_year
        dt = self.value.to_time.end_of_year
        self.set_value dt
        @engine.heap.it.set_to dt
      end

      #
      # Set the value to the beginning of the week.
      #
      def msg_begin_week
        dt = self.value.to_time.beginning_of_week( start_day = :sunday )
        self.set_value dt
        @engine.heap.it.set_to dt
      end

      #
      # Set the value to the end of the week.
      #
      def msg_end_week
        dt = self.value.to_time.end_of_week( start_day = :sunday )
        self.set_value dt
        @engine.heap.it.set_to dt
      end

      #
      # Set the value to the beginning of the day.
      #
      def msg_begin_day
        dt = self.value.to_time.beginning_of_day
        self.set_value dt
        @engine.heap.it.set_to dt
      end

      # 
      # Set the value to the end of the day.
      # 
      def msg_end_day
        dt = self.value.to_time.end_of_day
        self.set_value dt
        @engine.heap.it.set_to dt
      end

      #
      #
      # Tell the datetime to check if it is today.
      #
      def msg_is_today
        today = DtTools.is_today?( self.value )
        @engine.heap.it.set_to today
        return today
      end

      #
      # Tell the datetime to check if it is in the future.
      #
      def msg_is_future
        today = DtTools.is_future?( self.value )
        @engine.heap.it.set_to today
        return today
      end

      #
      # Tell the datetime to check if it is in the past.
      #
      def msg_is_past
        today = DtTools.is_past?( self.value )
        @engine.heap.it.set_to today
        return today
      end

      #
      # Tell the datetime to check if it is yesterday.
      #
      def msg_is_yesterday
        today = DtTools.is_yesterday?( self.value )
        @engine.heap.it.set_to today
        return today
      end

      #
      # Tell the datetime to check if it is tomorrow.
      #
      def msg_is_tomorrow
        today = DtTools.is_tomorrow?( self.value )
        @engine.heap.it.set_to today
        return today
      end

      #
      # Tell the datetime to check if it is this week.
      #
      def msg_is_this_week
        today = DtTools.is_this_week?( self.value )
        @engine.heap.it.set_to today
        return today
      end

      #
      # Set to the current date and time.
      #
      def msg_now
        self.set_value( DateTime.now )
        @engine.heap.it.set_to self.value
      end

      #
      # Format the date and time.
      #
      # @param format [String] The format to use.
      #
      def msg_format
        format = "%Y-%m-%d %H:%M:%S"
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
          format = data
        end
        dt = Chronic.parse( self.value )
        @engine.heap.it.set_to dt.strftime( format )
      end

    end
  end
end

