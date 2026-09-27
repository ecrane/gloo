# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# If the last command to run generated an error it will be here.
#

module Gloo
  module Core
    class Error

      # The kind of error: the command couldn't be understood (syntax),
      # or it was understood but couldn't be done (runtime).
      SYNTAX = 'syntax'.freeze
      RUNTIME = 'runtime'.freeze

      attr_accessor :value, :error_count, :kind, :location

      #
      # Set up the error object.
      #
      def initialize
        clear
      end

      #
      # Clear out the error message.
      #
      def clear
        @error_count = 0
        @value = nil
        @kind = nil
        @location = nil
      end

      #
      # Set the value of error.
      #
      def set_to( new_value, kind = RUNTIME, location = nil )
        @error_count += 1
        @value = new_value
        @kind = kind
        @location = location
      end

      #
      # Start counting errors.
      # We're looking to see if we get any new ones during
      # a script or an immediate command.
      #
      def start_tracking
        @error_count = 0
      end

      #
      # Clear out error if we didn't add any new ones.
      #
      def clear_if_no_errors
        self.clear if @error_count.zero?
      end

      #
      # Get the string representation of the error.
      #
      def to_s
        return @value.to_s
      end

      # 
      # Is this a function object?
      # 
      def is_function?
        return false
      end

    end
  end
end
