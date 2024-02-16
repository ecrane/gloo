# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# Run the documentation web server.
#

module Gloo
  module WebSvr
    class Doc

      #
      # Run the documentation server.
      #
      def self.run engine
        engine.log.info "Starting documentation web server…"
        TestServer.start
      end

    end
  end
end
