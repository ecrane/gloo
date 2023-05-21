# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# An action is a message sent to an object with optional parameters.
#

module Gloo
  module Exec
    class Action

      attr_accessor :msg, :to, :params

      #
      # Set up the action.
      #
      def initialize( msg, to, params = nil )
        @msg = msg
        @to = to
        @params = params
      end

      #
      # The action is valid if the object can receive
      # the message specified.
      #
      def valid?
        return @to.can_receive_message?( @msg )
      end

      #
      # Execute the action.
      # Dispatch the message to the object.
      #
      def dispatch
        @to.send_message @msg, @params
      end

      #
      # Generic function to get display value.
      # Can be used for debugging, etc.
      #
      def display_value
        return "#{@msg} -> #{@to.pn}"
      end

    end
  end
end
