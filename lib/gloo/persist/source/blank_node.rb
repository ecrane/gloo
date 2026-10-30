# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# A blank line between declarations. Kept (not discarded) so a save
# can reproduce the file's original spacing.
#

module Gloo
  module Persist
    module Source
      class BlankNode

        attr_reader :raw

        #
        # Set up a blank line node. raw is the full source line with its
        # line ending (none on a file's last line if the file doesn't end
        # with one); any trailing whitespace on the blank line is kept.
        #
        def initialize( raw = '' )
          @raw = raw
        end

        #
        # The node's exact source text.
        #
        def text
          return @raw
        end

      end
    end
  end
end
