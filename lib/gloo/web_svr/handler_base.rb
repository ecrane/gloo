# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# Base class for a request handler.
# Takes a request and does what is needed to create a response.
# 

module Gloo
  module WebSvr
    class HandlerBase
      
      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine )
        @engine = engine
        @log = @engine.log
      end


      # ---------------------------------------------------------------------
      #    Process Request
      # ---------------------------------------------------------------------

      #
      # Process the request and return a result.
      # 
      def handle request
        @request = request
        result = web? ? web_result : text_result
        return result
      end

      def web_result
        @log.debug 'processing html request…'
        msg = "<html><head><title>test web</title><body>Hello from Rack and Thin server.  at: #{Time.now}</body></html>"
        return Gloo::WebSvr::Response.html_response( @engine, msg )
      end
    
      def text_result
        @log.debug 'processing text request…'
        msg = "Hello from Rack and Thin server.  at: #{Time.now}"
        return Gloo::WebSvr::Response.text_response( @engine, msg )
      end
    
      def web?
        return @request.path == '/web'
      end
    
    
      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      # 
      # Write the request information to the log.
      # 
      def log
        @log.debug 'processing request…'
      end

    end
  end
end
