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
        engine.log.quiet = true

        web_server = Server.new( engine )
        web_server.start
        
        # Pause to give the server time to start.
        sleep( 1 )

        # Open the web page.
        url = "http://localhost:8087/"
        Gloo::Objs::Uri.open_url url

        # Show prompt to quit
        prompt = '<return> to quit the documentation web server >'
        engine.platform.prompt.ask( prompt )
      end

    end
  end
end
