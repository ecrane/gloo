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
    
      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[now is_today is_future is_past is_yesterday is_tomorrow is_this_week]
      end

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

    end
  end
end
