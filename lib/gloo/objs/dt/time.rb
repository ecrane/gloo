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
        return super + %w[now add sub hh mm ss am format]
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

      #
      # Get the hour.
      #
      def msg_hh
        dt = Chronic.parse( self.value )
        @engine.heap.it.set_to "#{dt.hour}".rjust(2, '0')
      end

      #
      # Get the minute.
      #
      def msg_mm
        dt = Chronic.parse( self.value )
        @engine.heap.it.set_to "#{dt.min}".rjust(2, '0')
      end

      #
      # Get the second.
      #
      def msg_ss
        dt = Chronic.parse( self.value )
        @engine.heap.it.set_to "#{dt.sec}".rjust(2, '0')
      end

      #
      # Get the AM/PM.
      #
      def msg_am
        dt = Chronic.parse( self.value )
        @engine.heap.it.set_to dt.strftime( '%p' )
      end

      #
      # Format the time.
      #
      # @param format [String] The format to use.
      #
      def msg_format
        format = "%H:%M:%S"
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
          format = data
        end
        dt = Chronic.parse( self.value )
        @engine.heap.it.set_to dt.strftime( format )
      end

      # ---------------------------------------------------------------------
      #    Object Documentation
      # ---------------------------------------------------------------------

      #
      # Get the object's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'A reference to a time, but without a date. ' \
            "The default format is: #{DEFAULT_FORMAT}. Note that you " \
            'can put a time into a datetime object. You can also put a ' \
            'Chronic phrase into the time.',
          :messages => [
            'now — Set to the current system time.',
            'add ({amount}) — Add the amount to the date. The amount will be in the form of "1 day" or "3 months".',
            'sub ({amount}) — Subtract the amount from the date. The amount will be in the form of "1 day" or "2 weeks".',
            'hh — Get the hour portion of the time. Put the hour into it.',
            'mm — Get the minute portion of the time. Put the minute into it.',
            'ss — Get the second portion of the time. Put the second into it.',
            'am — Get the am/pm portion of the time. Put "am" or "pm" into it.',
            'format ({fmt}) — Format the time using a strftime-style format string. Default if none given: %H:%M:%S. It will have the formatted string.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Show the current time.
            #

            time [can] :
              t [time] :
              on_load [script] :
                tell time.t to now
                show time.t
              next [script] :
                put '1 hour from now' into time.t
                show time.t
          EXAMPLES
        }
      end

    end
  end
end
