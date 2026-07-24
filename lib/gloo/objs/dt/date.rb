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
        return super + %w[now add sub mm dd yy yyyy format]
      end

      #
      # Set to the current date.
      #
      def msg_now
        self.set_value( DateTime.now )
        @engine.heap.it.set_to self.value
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
      # Get the month.
      #
      def msg_mm
        dt = Chronic.parse( self.value )
        @engine.heap.it.set_to "#{dt.month}".rjust(2, '0')
      end

      #
      # Get the day.
      #
      def msg_dd
        dt = Chronic.parse( self.value )
        @engine.heap.it.set_to "#{dt.day}".rjust(2, '0')
      end

      #
      # Get the year.
      #
      def msg_yyyy
        dt = Chronic.parse( self.value )
        @engine.heap.it.set_to dt.year.to_s
      end

      #
      # Get the year (2 digit).
      #
      def msg_yy
        dt = Chronic.parse( self.value )
        @engine.heap.it.set_to dt.year.to_s[-2..-1]
      end

      # 
      # Format the date.
      #
      # @param format [String] The format to use.
      #
      def msg_format
        format = "%Y-%m-%d"
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
          :description => 'A reference to a date, but without time. The ' \
            "default format is: #{DEFAULT_FORMAT}. Note that you can " \
            'put a date into a datetime object. You can also put a ' \
            'Chronic phrase into the date.',
          :messages => [
            'now — Set to the current system date.',
            'add ({amount}) — Add the amount to the date. The amount will be in the form of "1 day" or "3 months".',
            'sub ({amount}) — Subtract the amount from the date. The amount will be in the form of "1 day" or "2 weeks".',
            'dd — Get the day portion of the date. Put the day number into it.',
            'mm — Get the month portion of the date. Put the month number into it.',
            'yy — Get the 2 digit year portion of the date. Put the 2 digit year into it.',
            'yyyy — Get the 4 digit year portion of the date. Put the 4 digit year into it.',
            'format ({fmt}) — Format the date using a strftime-style format string. Default if none given: %Y-%m-%d. It will have the formatted string.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Show the current date.
            #

            date [can] :
              d [date] :
              on_load [script] :
                tell date.d to now
                show date.d
              next [script] :
                put 'tomorrow' into date.d
                show date.d
          EXAMPLES
        }
      end

    end
  end
end
