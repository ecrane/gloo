# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# Web application request handler.
# Application is running in gloo.
# 

module Gloo
  module WebSvr
    class AppSvr < Gloo::WebSvr::Handler

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

    end
  end
end
