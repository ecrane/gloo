# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# Web application request handler.
# Takes a request and does what is needed to create a response.
# 

module Gloo
  module WebSvr
    class Handler
      
      attr_reader :server_obj, :asset


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

        @asset = Gloo::WebSvr::Asset.new( @engine, @server_obj )
      end


      # ---------------------------------------------------------------------
      #    Process Request
      # ---------------------------------------------------------------------

      #
      # Process the request and return a result.
      # 
      def handle request
        @request = request

        page = @server_obj.router.page_for_route @request.path
        if page
          if page.is_a? Gloo::Objs::FileHandle
            return handle_file page
          else
            return handle_page page
          end
        end

        return server_error_result
      end

      # 
      # Handle request for a page.
      # Render the page, with possible redirect.
      # 
      def handle_page page
        result = page.render
        if redirect_set?
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
        pn = @asset.path_for_file file

        # Check to make sure it is a valid file
        # return error if it is not
        return file_error_result unless File.exist? pn

        # TODO: handle mltiple kinds of files -- HOW?
        # Use file name extension to determine type.

        data = File.binread( pn )
        return Gloo::WebSvr::Response.image_response( @engine, data )
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
