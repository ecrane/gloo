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
require 'base64'

module Gloo
  module WebSvr
    class Session

      SESSION_CONTAINER = 'session'.freeze
      SESSION_ID_NAME = 'session_id'.freeze

      
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
        @include_in_response = false
        @clearing_session = false
      end


      # ---------------------------------------------------------------------
      #    Set Session Data for Request
      # ---------------------------------------------------------------------

      # 
      # Get the session data from the encrypted cookie.
      # Add it to the session container.
      # 
      def set_session_data_for_request( env )
        begin
          cookie_hash = Rack::Utils.parse_cookies( env )

          # Are we using sessions?
          if @server_obj.use_session?
            data = cookie_hash[ session_name ]

            if data
              data = decode_decrypt( data ) 
              return unless data
              
              @session_id = data[ SESSION_ID_NAME ]

              data.each do |key, value|
                unless key == SESSION_ID_NAME
                  @server_obj.set_session_var( key, value )
                end
              end
            end
          end
        rescue => e
          @engine.log_exception e
        end
      end


      # ---------------------------------------------------------------------
      #    Set Session Data for Response
      # ---------------------------------------------------------------------

      # 
      # Temporarily set the flag to add the session data to the response.
      # Once this is done, the flag will be cleared and it will not
      # be added to the next request unless specifically set.
      # 
      def add_session_to_response
        @include_in_response = true
      end

      def init_session_id
        @session_id = Gloo::Objs::CsrfToken.generate_csrf_token
        return @session_id
      end

      # 
      # Initialize the session id and add it to the data.
      # Use the current session ID if it is there.
      # 
      def get_session_id
        if @clearing_session
          @clearing_session = false
          return nil
        end

        init_session_id if @session_id.blank?

        return @session_id
      end

      # 
      # Clear out the session Id.
      # Set the flag to add the session data to the response.
      # 
      def clear_session_data
        @session_id = nil
        @clearing_session = true
        add_session_to_response
      end

      # 
      # If there is session data, encrypt and add it to the response.
      # Once done, clear out the session data.
      # 
      def add_session_for_response( headers )
        # Are we using sessions?
        if @server_obj.use_session? && @include_in_response
          # Reset the flag because we are adding to the session data now
          @include_in_response = false

          # Build and add encrypted session data
          data = @server_obj.get_session_data
          data[ SESSION_ID_NAME ] = get_session_id

          unless data.empty?
            data = encrypt_encode( data )
            session_hash = { 
              value: data, 
              path: cookie_path, 
              expires: cookie_expires,
              http_only: true }

            if secure_cookie?
              session_hash[ :secure ] = true
            end

            Rack::Utils.set_cookie_header!( headers, session_name, session_hash )
          end
        end

        return headers
      end


      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      # 
      # Encrypt and encode the session data.
      # 
      def encrypt_encode( data )
        return Gloo::Objs::Cipher.encrypt( data.to_json, key, iv )
      end

      # 
      # Decode and decrypt the session data.
      # 
      def decode_decrypt( data )
        return nil unless data && key && iv

        data = Gloo::Objs::Cipher.decrypt( data, key, iv )
        return JSON.parse( data )
      end

      # 
      # Get the session cookie name.
      # 
      def session_name
        return @server_obj.session_name
      end

      # 
      # Get the key for the encryption cipher.
      # 
      def key
        return @server_obj.encryption_key
      end

      # 
      # Get the initialization vector for the cipher.
      # 
      def iv
        return @server_obj.encryption_iv
      end

      # 
      # Get the path for the session cookie.
      # 
      def cookie_path
        return @server_obj.session_cookie_path
      end

      # 
      # Get the expiration time for the session cookie.
      # 
      def cookie_expires
        return @server_obj.session_cookie_expires
      end

      # 
      # Should the session cookie be secure?
      # 
      def secure_cookie?
        return @server_obj.session_cookie_secure
      end

    end
  end
end
