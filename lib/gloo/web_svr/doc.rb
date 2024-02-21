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

        config = Gloo::WebSvr::Config.doc_config engine 
        engine.log.info "Doc Server URL: #{config.base_url}"

        handler = Gloo::WebSvr::HandlerBase.new engine
        web_server = Server.new( engine, handler, config )
        web_server.start
        
        # Pause to give the server time to start.
        sleep( 1 )

        # Open the web page.
        Gloo::Objs::Uri.open_url config.base_url

        # Show prompt to quit
        prompt = '<return> to quit the documentation web server >'
        engine.platform.prompt.ask( prompt )
      end

    end
  end
end
