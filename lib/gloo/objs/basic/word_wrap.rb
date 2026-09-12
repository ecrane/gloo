# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Word-wrapping utility.
# This is a static class.
#

module Gloo
  module Objs
    class WordWrap

      # ---------------------------------------------------------------------
      #    Wrapping
      # ---------------------------------------------------------------------

      #
      # Wrap the given text to the given column width.
      # Greedy word-wrap: breaks on whitespace, never mid-word. A single
      # word longer than the width is left on its own line rather than
      # being hard-broken (e.g. a URL stays intact, just overflows).
      # Existing line breaks in the text are preserved -- each line is
      # wrapped independently, so blank lines and paragraph breaks survive.
      #
      def self.wrap( text, width )
        return text.to_s if width.to_i <= 0

        text.to_s.split( "\n", -1 ).map { |line| wrap_line( line, width ) }.join( "\n" )
      end

      # ---------------------------------------------------------------------
      #    Private
      # ---------------------------------------------------------------------

      #
      # Wrap a single line (no embedded newlines) to the given width.
      #
      def self.wrap_line( line, width )
        words = line.split( ' ' )
        return line if words.empty?

        lines = []
        current = words.shift
        words.each do |word|
          if "#{current} #{word}".length > width
            lines << current
            current = word
          else
            current = "#{current} #{word}"
          end
        end
        lines << current
        return lines.join( "\n" )
      end
      private_class_method :wrap_line

    end
  end
end
