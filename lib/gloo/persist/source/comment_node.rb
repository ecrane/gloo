# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# A whole-line comment that is not attached to any object declaration
# as its leading_doc -- either because a blank line separated it from
# the declaration that follows, or nothing follows it at all.
#

module Gloo
  module Persist
    module Source
      class CommentNode

        attr_reader :raw

        #
        # Set up a comment node. raw is the full source line, minus
        # its trailing newline.
        #
        def initialize( raw )
          @raw = raw
        end

      end
    end
  end
end
