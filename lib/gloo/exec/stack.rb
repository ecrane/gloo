# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A stack of items, a call stack.
#

module Gloo
  module Exec
    class Stack

      attr_accessor :stack
      
      #
      # Set up the stack.
      #
      def initialize( name )
        @name = name
        clear_stack
        $log.debug "#{name} stack intialized..."
      end

      #
      # Push an item onto the stack.
      #
      def push( obj )
        $log.debug "#{@name}:push #{obj.display_value}"
        @stack.push obj
        self.update_out_file if $settings.debug
      end

      #
      # Pop an item from the stack.
      #
      def pop
        o = @stack.pop
        $log.debug "#{@name}:pop #{o.display_value}"
        self.update_out_file if $settings.debug
      end

      #
      # Get the current size of the call stack.
      #
      def size
        return @stack.size
      end

      #
      # Get stack data for output.
      #
      def out_data
        return @stack.map( &:display_value ).join( "\n" )
      end

      #
      # Get the file we'll write debug information for the stack.
      #
      def out_file
        return File.join( $settings.debug_path, @name )
      end

      #
      # Update the stack trace file.
      #
      def update_out_file
        File.write( self.out_file, self.out_data )
      end

      #
      # Clear the stack and the output file.
      #
      def clear_stack
        @stack = []
        self.update_out_file
      end

    end
  end
end
