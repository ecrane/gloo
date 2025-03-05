# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A Date object (does not include a time).
#

module Gloo
  module Objs
    class Date < Gloo::Core::Obj

      KEYWORD = 'date'.freeze
      KEYWORD_SHORT = 'date'.freeze
      DEFAULT_FORMAT = '%Y.%m.%d'.freeze

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
          self.value = @engine.converter.convert( new_value, 'Date', nil )
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
        return super + %w[now]
      end

      #
      # Set to the current date.
      #
      def msg_now
        self.set_value( DateTime.now )
        @engine.heap.it.set_to self.value
      end

    end
  end
end
