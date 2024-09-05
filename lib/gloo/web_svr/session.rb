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
        data = cookie_hash[ session_name ]

        if data
          data = decode_decrypt( data ) 
          # puts "Session Data: #{data}"

          data.each do |key, value|
            puts "#{key} : #{value}"
          end
        end
      end


      # ---------------------------------------------------------------------
      #    Get Session Data for Response
      # ---------------------------------------------------------------------

      def add_session_for_response( headers )
        # 
        # TO DO: build encrypted session data
        # 
        data = { user: 'ecrane', id: 123 }
        data = encrypt_encode( data )
        session_hash = { value: data, path: "/", http_only: true, Secure: true }
        
        Rack::Utils.set_cookie_header!( headers, session_name, session_hash )

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
        # 
        #  TO DO: Get session cookie name from settings/config
        # 
        return '_gloo_session'
      end

      # 
      # Get the key for the encryption cipher.
      # 
      def key
        # 
        # TO DO: Get key from settings/config
        # 
        return "rJ6xrgFwX5tJ8aOiI2RHOsib4vCqEwbHKvmCwTR84kk="
      end

      # 
      # Get the initialization vector for the cipher.
      # 
      def iv
        # 
        # TO DO: Get iv from settings/config
        # 
        return "90xzPMD4u+IJMuCyPe6SZQ=="
      end

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
