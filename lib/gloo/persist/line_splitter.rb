# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Helper class used as part of file loading.
# It is responsible for splitting a line into components.
#

module Gloo
  module Persist
    class LineSplitter

      BEGIN_BLOCK = 'BEGIN'.freeze
      END_BLOCK = 'END'.freeze

      attr_reader :obj

      #
      # Set up a line splitter
      #
      def initialize( line, tabs )
        @line = line
        @tabs = tabs
      end

      #
      # Split the line into 3 parts.
      #
      def split
        detect_name
        detect_type
        detect_value

        return @name, @type, @value
      end

      #
      # Detect the object name.
      #
      def detect_name
        @line = @line.strip
        @idx = @line.index( ' ' )
        @name = @line[ 0..@idx - 1 ]
      end

      #
      # Detect the object type.
      #
      def detect_type
        @line = @line[ @idx + 1..-1 ]
        @idx = @line.index( ' ' )

        if @line[ 0 ] == ':'
          @type = 'untyped'
          return
        end

        @type = @line[ 0..( @idx ? @idx - 1 : -1 ) ]
        @type = @type[ 1..-1 ] if @type[ 0 ] == '['
        @type = @type[ 0..-2 ] if @type[ -1 ] == ']'
      end

      #
      # Detect the object value.
      # Use nil if there is no value specified.
      #
      def detect_value
        if @idx
          @value = @line[ @idx + 1..-1 ]
          if @value[ 0..1 ] == ': '
            @value = @value[ 2..-1 ]
          elsif @value[ 0 ] == ':'
            @value = @value[ 1..-1 ]
          end
        else
          @value = nil
        end
      end

    end
  end
end
