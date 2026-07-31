# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Lightly colorize markdown for terminal display: headings and code
# fences get ANSI color, everything else passes through unchanged.
# Not a full markdown renderer - just enough that the raw
# `#`/```` ``` ```` syntax doesn't have to be read literally.
#
# Shared by the narrative doc pages (dev/gloo/docs/*.md) and the
# verb/object detail pages (Gloo::Docs::DocData#render), so both are
# paged through the same visual style.
#
module Gloo
  module Docs
    class MarkdownRenderer

      #
      # Colorize the given markdown text for terminal display.
      def self.colorize( text )
        in_code = false
        lines = text.split( "\n" ).map do |line|
          if line.start_with?( '```' )
            in_code = !in_code
            next line.light_black
          end
          next line.light_black if in_code
          next line.sub( /^#\s*/, '' ).blue.bold if line.start_with?( '# ' )
          next line.sub( /^##\s*/, '' ).cyan.bold if line.start_with?( '## ' )
          next line.cyan if line.start_with?( '### ' ) || line.start_with?( '#### ' )
          next line.light_black if line =~ /\A-{3,}\z/

          line
        end
        return lines.join( "\n" )
      end

    end
  end
end
