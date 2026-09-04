# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# A top-of-file 'load lib {name}' (or 'load ext {name}') directive,
# run by the loader itself before the declarations that follow it.
#

module Gloo
  module Persist
    module Source
      class DirectiveNode

        attr_reader :raw

        #
        # Set up a directive node. raw is the full source line, minus
        # its trailing newline.
        #
        def initialize( raw )
          @raw = raw
        end

      end
    end
  end
end
