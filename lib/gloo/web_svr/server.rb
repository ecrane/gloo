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

      def call( env )
        start_handling
        show_request env
    
        if web?( env )
          result = web_result
        else
          result = text_result
        end
    
        finish_handling
        return result
      end

      # ---------------------------------------------------------------------
      #    Request timer
      # ---------------------------------------------------------------------

      # 
      # Keep track of the request start time.
      # 
      def start_handling
        @start = Time.now
    
        @cnt = 0 unless @cnt
        @cnt += 1
      end
    
      # 
      # Write the request completion time to the log.
      # 
      def finish_handling
        @finish = Time.now
        @elapsed = ( ( @finish - @start ) * 1000.0 ).round(2)
        @log.info "Web request complete.  Elapsed time: #{@elapsed} ms"
      end
    
      def web_result
        msg = "<html><head><title>test web</title><body>#{@cnt}.  Hello from Rack and Thin server.  at: #{Time.now}</body></html>"
        return [ 200, { "Content-Type" => "text/html" }, msg ]
      end
    
      def text_result
        msg = "#{@cnt}.  Hello from Rack and Thin server.  at: #{Time.now}"
        @log.debug msg
        return [ 200, { "Content-Type" => "text/plain" }, msg ]
      end
    
      def web? env
        return env[ 'REQUEST_PATH' ] == '/web'
      end
    
      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      def show_request env
        @log.debug "REQUEST_METHOD: #{env[ 'REQUEST_METHOD' ] }"
        @log.debug "REQUEST_PATH: #{env[ 'REQUEST_PATH' ] }"
        @log.debug "HTTP_HOST: #{env[ 'HTTP_HOST' ] }"
        @log.debug "QUERY_STRING: #{env[ 'QUERY_STRING' ] }"    
      end
    
    end
  end
end

