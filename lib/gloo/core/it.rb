# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# It is the value of the last command that was run.
#

module Gloo
  module Core
    class It

      attr_accessor :value

      #
      # Set up the object.
      #
      def initialize
        @value = nil
      end

      #
      # Set the value of it.
      #
      def set_to( new_value )
        @value = new_value
      end

      #
      # Get the string representation of it.
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

      # 
      # Is [it] true?
      # 
      def is_true?
        return @value == true
      end

      # 
      # Is [it] false?
      # 
      def is_false?
        return @value == false
      end

    end
  end
end
