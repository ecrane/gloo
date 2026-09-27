# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A script to be run.
#

module Gloo
  module Exec
    class Script

      attr_accessor :obj
      #
      # Set up the script.
      #
      def initialize( engine, obj )
        @engine = engine
        @obj = obj
        @break_out = false
        @line = 0
      end

      #
      # Run the script.
      # The script might be a single string or an array
      # of lines.
      #
      def run
        @engine.exec_env.push_script self

        if @obj.value.is_a? String
          @line = 1
          @engine.parser.run @obj.value
        elsif @obj.value.is_a? Array
          @obj.value.each_with_index do |line, i|
            break if @break_out

            @line = i + 1
            @engine.parser.run line
          end
        end

        @engine.exec_env.pop_script
      end

      #
      # Where this script is in its run: its path and the line now
      # running (counting from 1), for error messages.
      #
      def location
        return "#{@obj.pn}, line #{@line}"
      end

      #
      # Generic function to get display value.
      # Can be used for debugging, etc.
      #
      def display_value
        return @obj.pn
      end

      # 
      # Stop running this script.
      # 
      def break_out
        @break_out = true
      end

    end
  end
end
