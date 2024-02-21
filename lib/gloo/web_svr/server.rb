# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
# 
# Starting work on web server inside gloo.
# 
#  UNDER CONSTRUCTION!
# 
# Simple tests:
#   > curl http://localhost:8087/test/
#   > curl http://localhost:8087/web/
#   > curl http://localhost:8087/test/1
#   > curl http://localhost:8087/test?param=123
# 
# Run in loop:
#  for i in {1..99}; do curl http://localhost:8087/; done
# 
# Links:
#   https://github.com/rack/rack
#   https://github.com/rack/rack/blob/main/lib/rack/builder.rb
#   https://thoughtbot.com/blog/ruby-rack-tutorial
#   https://www.rubydoc.info/gems/rack/1.5.5/Rack/Runtime
# 

require 'rack'

module Gloo
  module WebSvr
    class Server
    
      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine, config = nil )
        @config = config ? config : Gloo::WebSvr::Config.new
        @engine = engine
        @log = @engine.log

        @log.debug 'Gloo web server intialized…'
      end


      # ---------------------------------------------------------------------
      #    Start and Stop the server.
      # ---------------------------------------------------------------------

      # 
      # Start the web server.
      # 
      def start
        opts = {
          :Port => @config.port,
          :Host => @config.host
        }
        Thread.abort_on_exception = true
        @server_thread = Thread.new { Rack::Handler::Thin.run( self, **options=opts ) }
        @log.debug 'Web server has started.'
      end

      # 
      # Stop the web server
      # 
      def stop
        @log.debug 'Stopping the web server…'

        @server_thread.stop

        @log.debug 'The web server has been stopped.'
      end


      # ---------------------------------------------------------------------
      #    Handle events
      # ---------------------------------------------------------------------

      # 
      # Handle a request for a resource.
      # 
      def call( env )
        request = Gloo::WebSvr::Request.new( @engine, env )
        request.log

        response = request.process
        response.log
        
        return response.result
      end

    
    end
  end
end

