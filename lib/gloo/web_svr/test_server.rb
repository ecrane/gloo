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
    class TestServer

      PORT = 8087
    
      def self.start
        opts = {
          :Port => PORT,
          :Host => 'localhost'
        }
        Rack::Handler::Thin.run( TestServer.new, **options=opts )
      end
    
      def call( env )
        start_handling
        show_request env
    
        result = web?( env ) ? web_result : text_result
    
        finish_handling
        return result
      end
    
      def start_handling
        @start = Time.now
    
        @cnt = 0 unless @cnt
        @cnt += 1
      end
    
      def finish_handling
        @finish = Time.now
        @elapsed = ( ( @finish - @start ) * 1000.0 ).round(2)
        puts "*** Elapsed time: #{@elapsed} ms"
      end
    
      def web_result
        msg = "<html><head><title>test web</title><body>#{@cnt}.  Hello from Rack and Thin server.  at: #{Time.now}</body></html>"
        return [ 200, { "Content-Type" => "text/html" }, msg ]
      end
    
      def text_result
        msg = "#{@cnt}.  Hello from Rack and Thin server.  at: #{Time.now}\n"
        puts msg
        return [ 200, { "Content-Type" => "text/plain" }, msg ]
      end
    
      def web? env
        return env[ 'REQUEST_PATH' ] == '/web'
      end
    
      def show_request env
        puts "REQUEST_METHOD: #{env[ 'REQUEST_METHOD' ] }"
        puts "REQUEST_PATH: #{env[ 'REQUEST_PATH' ] }"
        puts "HTTP_HOST: #{env[ 'HTTP_HOST' ] }"
        puts "QUERY_STRING: #{env[ 'QUERY_STRING' ] }"    
      end
    
    end
  end
end

