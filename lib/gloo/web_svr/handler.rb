# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
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
        page_obj = nil
        @route_params = nil

        page, id, @route_params = @server_obj.router.page_for_route( @request.path, @request.method )
        @engine.log.debug "Found Page: #{page&.name}" if page
        request.id = id
        if page
          if page.is_a? Gloo::Objs::FileHandle
            result = handle_file page
          else
            result = handle_page page
            page_obj = page
          end
        else
          result = server_error_result
        end

        return result, page_obj
      end

      # 
      # Handle request for a page.
      # Render the page, with possible redirect.
      # 
      def handle_page page
        result = page.render @request, @route_params
        if redirect_hard_set?
          result = server_error_result
          @engine.running_app.obj.redirect_hard = nil
        elsif redirect_set?
          page = @engine.running_app.obj.redirect
          @log.debug "Redirecting to: #{page.pn}"
          @engine.running_app.obj.redirect = nil
          result = page.render
        end
        return result
      end

      # 
      # Handle a request for a static file such as an image.
      # 
      def handle_file file
        pn = @server_obj.asset.path_for_file file

        # Check to make sure it is a valid file
        # return error if it is not
        return file_error_result unless File.exist? pn

        return @server_obj.asset.render_file pn
      end


      # ---------------------------------------------------------------------
      #    Errors
      # ---------------------------------------------------------------------

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
    
      # 
      # Get a file not found error result.
      # 
      def file_error_result
        return Gloo::WebSvr::Response.text_response( @engine, 
          "File not found!", Gloo::WebSvr::ResponseCode::NOT_FOUND )
      end    


      # ---------------------------------------------------------------------
      #    Redirect Helper functions
      # ---------------------------------------------------------------------

      # 
      # Is there a redirect page set in the running app?
      # 
      def redirect_set?
        return false unless @engine.app_running?
        return @engine.running_app.obj.redirect
      end

      # 
      # Is there a redirect page set in the running app?
      # 
      def redirect_hard_set?
        return false unless @engine.app_running?
        return @engine.running_app.obj.redirect_hard
      end

      # 
      # Return a redirect result.
      # 
      def server_error_result
        target = @engine.running_app.obj.redirect_hard

        return Gloo::WebSvr::Response.redirect_response( @engine, target )
      end    

    end
  end
end
