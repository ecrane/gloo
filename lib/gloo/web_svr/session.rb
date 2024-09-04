# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Helpers for getting and setting session data.
# 
# Resources:
#   https://www.rubydoc.info/gems/rack/1.5.5/Rack/Request#cookies-instance_method
#   https://rubydoc.info/github/rack/rack/Rack/Utils#set_cookie_header-class_method
#   https://en.wikipedia.org/wiki/HTTP_cookie
#   

module Gloo
  module WebSvr
    class Session

      SESSION_CONTAINER = 'session'.freeze

      
      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine, server_obj )
        @engine = engine
        @log = @engine.log

        @server_obj = server_obj
      end


      # ---------------------------------------------------------------------
      #    Set Session Data for Request
      # ---------------------------------------------------------------------

      # 
      # Get the session data from the encrypted cookie.
      # Add it to the session container.
      # 
      def set_session_data_for_request( env )

        # puts "************************************************"
        # puts Rack::Utils.parse_cookies( env )
        # puts "************************************************"

      end


      # ---------------------------------------------------------------------
      #    Get Session Data for Response
      # ---------------------------------------------------------------------

      def add_session_for_response( headers )

        # 
        #  TO DO: Get cookie from settings/config
        # 
        
        # puts "Headers: #{headers}"
        # Rack::Utils.set_cookie_header!( headers, "_gloo_session_test", { value: "test", path: "/", http_only: 1, Secure: 1, expires: Time.now } )
        Rack::Utils.set_cookie_header!( headers, "_gloo_session_test", { value: "test", path: "/", http_only: true, Secure: true } )
        # puts "Headers after: #{headers}"

        return headers
      end

      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      # 
      # Clear out all session data.
      # Important to do this after the response is sent
      # to avoid holding on to data that is no longer needed.
      # 
      def clear_session_data
      end

      # 
      # Add the session container if it is missing.
      # 
      def add_container_if_missing

      end

      # 
      # Write the request information to the log.
      # 
      def log
        @log.info "#{@method} #{@host}#{@path}"
        @log.info "Parameters: #{@query}"
        @log.info "Body: #{@body}" unless @body.empty?
      end

    end
  end
end
