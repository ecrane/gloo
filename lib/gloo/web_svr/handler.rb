# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# Web application request handler.
# Takes a request and does what is needed to create a response.
# 

module Gloo
  module WebSvr
    class Handler
      
      attr_reader :server_obj

      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine, obj )
        @engine = engine
        @log = @engine.log
        @server_obj = obj
      end


      # ---------------------------------------------------------------------
      #    Process Request
      # ---------------------------------------------------------------------

      #
      # Process the request and return a result.
      # 
      def handle request
        @request = request

        page = @server_obj.page_for_route @request.path
        if page
          result = page.render
          if redirect_set?
            page = @engine.running_app.redirect
            @log.debug "Redirecting to: #{page.pn}"
            @engine.running_app.redirect = nil
            result = page.render
          end
        else
          result = server_error_result
        end

        return result
      end

      # 
      # Return a server error result.
      # Use the app's error if there is one, otherwise a generic message.
      # 
      def server_error_result
        # TODO: use the app's error if there is one.

        msg = "Server error.  at: #{Time.now}"
        return Gloo::WebSvr::Response.text_response( @engine, msg )
      end    
    
      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      # 
      # Is there a redirect page set in the running app?
      # 
      def redirect_set?
        app = @engine.running_app
        return app && app.redirect
      end

    end
  end
end
