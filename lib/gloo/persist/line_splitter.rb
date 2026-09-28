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

      attr_reader :obj, :raw_tail, :missing_bracket

      #
      # Set up a line splitter
      #
      def initialize( line, tabs )
        @line = line
        @tabs = tabs
        @raw_tail = ''
        @missing_bracket = false
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
      # Only leading whitespace (the indentation, captured separately by
      # the loader) and the trailing newline are removed here --
      # trailing spaces/tabs are left on the line so they survive into
      # a string value, which can matter when the value is used to
      # build HTML.
      #
      # A line that starts with the type ('[') or the value (':') has no
      # name: the name is nil, and the whole line is left for the type
      # and value.
      #
      def detect_name
        @line = @line.lstrip.chomp
        if @line.start_with?( '[', ':' )
          @name = nil
          @line = " #{@line}"
          @idx = 0
          return
        end

        @idx = @line.index( ' ' )
        @idx = 0 unless @idx
        @name = @line[ 0..@idx - 1 ]
      end

      #
      # Detect the object type, and capture the exact source text that
      # follows it -- everything from the closing ']' (or, for an
      # untyped declaration with no brackets at all, from right after
      # the name) to the end of the line. Kept byte-exact so a save can
      # reproduce a declaration's original spacing when its value
      # hasn't changed.
      #
      # A type that opens with '[' but has no ']' (eg. 'a [int : 3') is
      # read up to the next space, as if it were closed there; the tail
      # is everything after it, and missing_bracket is set so the loader
      # can report it. A ']' later on the line (in the value) doesn't
      # count.
      #
      def detect_type
        @line = @line[ @idx + 1..-1 ]
        @idx = @line.index( ' ' )

        if @line[ 0 ] == ':'
          @type = 'untyped'
          @raw_tail = @line
          return
        end

        word = @line[ 0..( @idx ? @idx - 1 : -1 ) ]
        return detect_bracketed_type( word ) if word[ 0 ] == '['

        @type = word
        @type = @type[ 0..-2 ] if @type[ -1 ] == ']'
        close = @line.index( ']' )
        @raw_tail = close ? @line[ close + 1..-1 ] : ''
      end

      #
      # The type word starts with '['. The type ends at the ']' in that
      # word (which may be followed directly by the ':', as in
      # 'a [int]: 3'); with no ']' in it, the whole word is the type.
      #
      def detect_bracketed_type( word )
        close = word.index( ']' )
        if close
          @type = word[ 1...close ]
          @raw_tail = @line[ close + 1..-1 ]
        else
          @missing_bracket = true
          @type = word[ 1..-1 ]
          @raw_tail = @idx ? @line[ @idx..-1 ] : ''
        end
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
