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
        # Set up a blank line node. raw is the full source line, minus
        # its trailing newline (may be non-empty if the blank line had
        # trailing whitespace -- preserved rather than normalized).
        #
        def initialize( raw = '' )
          @raw = raw
        end

      end
    end
  end
end
