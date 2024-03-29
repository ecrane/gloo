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
            page = @engine.running_app.obj.redirect
            @log.debug "Redirecting to: #{page.pn}"
            @engine.running_app.obj.redirect = nil
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
          err_page = @server_obj.err_page
          return err_page.render if err_page

          # Last resort, just return a generic error message.
          return Gloo::WebSvr::Response.text_response( @engine, 
            "Server error!", Gloo::WebSvr::ResponseCode::SERVER_ERR )
      end    
    
      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      # 
      # Is there a redirect page set in the running app?
      # 
      def redirect_set?
        return false unless @engine.app_running?
        return @engine.running_app.obj.redirect
      end

    end
  end
end
