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
      attr_reader :query_params, :body_params, :body_binary
      
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
        if body && body.length > 0
          # if body is binary, then it is not a query string
          begin
            @body_params = Rack::Utils.parse_query body
          rescue => exception
            init_multipart body 
          end
        else
          @body_params = {} 
        end
      end

      # 
      # Set the body to a binary file.
      # 
      # TODO: find a lib or method to handle this.
      # This is very rough and will need to be fixed.
      # 
      def init_multipart body
        # puts "*********** first lines: *********** "
        # body.lines[0..3].each { |line| puts line }
        # puts "*********** last lines: *********** "
        # body.lines.last(5).each { |line| puts line }
        # puts "************************************"

        # boundary = body.lines.first
        # puts "boundary: #{boundary}"

        header = body.lines[1..3].join
        # puts "header: #{header}"

        footer = body.lines.last(5).join
        # puts "footer: #{footer}"

        binary_data = body.lines[4..-6].join
        # puts "binary_data length: #{binary_data.length}"
        # puts "binary first line: #{binary_data.lines.first}"
        # puts "binary last line: #{binary_data.lines.last}"

        i = header.lines.first.index( 'filename=' )
        filename = header.lines.first[ i+10..-4 ]
        content_type = header.lines.second[14..-3]
        # puts "filename: #{filename}"
        # puts "content_type: #{content_type}"

        @body_binary = body
        @body_params = {}
        @body_params[ 'content_type' ] = content_type
        @body_params[ 'file_name' ] = filename
        @body_params[ 'file_size' ] = binary_data.length
        @body_params[ 'file_data' ] = binary_data
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
          if @body_params[ 'file_data' ]
            # exclude the file data from the params shown
            params = @body_params.dup
            params.delete( 'file_data' )
            params[ 'file_data' ] = '...'
            @log.info "--- Body Parameters: #{params}"
          else
            @log.info "--- Body Parameters: #{@body_params}"
          end
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
