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
        cookie_hash = Rack::Utils.parse_cookies( env )

        # Are we using sessions?
        if @server_obj.use_session?
          data = cookie_hash[ session_name ]

          if data
            data = decode_decrypt( data ) 

            data.each do |key, value|
              @server_obj.set_session_var( key, value )
            end
          end
        end

      end


      # ---------------------------------------------------------------------
      #    Get Session Data for Response
      # ---------------------------------------------------------------------

      # 
      # If there is session data, encrypt and add it to the response.
      # Once done, clear out the session data.
      # 
      def add_session_for_response( headers )
        # Are we using sessions?
        if @server_obj.use_session?
          # Build and add encrypted session data
          data = @server_obj.get_session_data
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

          # Clear out session data
          @server_obj.clear_session_data
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
