# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A Parameters associated with a request.
#
# Kinds of Params
#   Id - The entity id
#   Key - URL parameter key
#   URL Params - Parameters in the URL
#   Body Params - Data from the body of the request
# 

module Gloo
  module WebSvr
    class RequestParams

      attr_accessor :id, :route_params
      attr_reader :query_params, :body_params
      
      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( log )
        @log = log
      end


      # ---------------------------------------------------------------------
      #    Value Detection
      # ---------------------------------------------------------------------

      # 
      # Detect the parameters from query string.
      # 
      def init_query_params query_string
        if query_string
          @query_params = Rack::Utils.parse_query( query_string )
        else
          @query_params = {} 
        end
      end

      # 
      # Detect the parameters from the body of the request.
      # 
      def init_body_params body
        if body
          @body_params = Rack::Utils.parse_query body
        else
          @body_params = {} 
        end
      end


      # ---------------------------------------------------------------------
      #    Authenticity Token checking
      # ---------------------------------------------------------------------

      # 
      # Check the authenticity token if it is present.
      # Returns true if it is present and valid, and
      # also if it is not present.
      # Returns false if it is present but not valid.
      # 
      def check_authenticity_token engine
        auth_token = @query_params[ Gloo::Objs::CsrfToken::AUTHENTICITY_TOKEN ]
        if auth_token
          session_id = engine.running_app.obj&.session&.get_session_id
          return false unless session_id

          return Gloo::Objs::CsrfToken.valid_csrf_token?( session_id, auth_token )
        end

        return true
      end


      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      # 
      # Check the body to see if there is a PATCH or a PUT in 
      # the method override.
      # 
      def get_body_method_override orig_method
        if @body_params[ '_method' ]
          return @body_params[ '_method' ].upcase
        end
        return orig_method
      end

      # 
      # Write the querey and body params to the log.
      # 
      def log_params
        return unless @log

        if @query_params && ! @query_params.empty?
          @log.info "--- Query Parameters: #{@query_params}" 
        end

        if @body_params && ! @body_params.empty?
          @log.info "--- Body Parameters: #{@body_params}"
        end
      end

      # 
      # Write the id and route params to the log.
      # 
      def log_id_keys
        return unless @log

        @log.info "--- ID Parameter: #{@id}" if @id

        if @route_params && ! @route_params.empty?
          @log.info "--- Route Parameters: #{@route_params}"
        end
      end

    end
  end
end
