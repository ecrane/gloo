# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A web Request for a page, action, or static resource.
#
# Kinds of Resources
#   Web Page
#   Action - does something and redirects to a page (or returns nothing)
#   API - returns JSON instead of HTML (but is that different from Web Page?)
#   Static Resource - File, PDF, Image, etc.
# 
# 
# See More doc here:
#    https://www.rubydoc.info/gems/rack/Rack/Request/Helpers#path-instance_method
# 

module Gloo
  module WebSvr
    class Request

      REQUEST_METHOD = 'REQUEST_METHOD'.freeze
      REQUEST_PATH = 'REQUEST_PATH'.freeze
      HTTP_HOST = 'HTTP_HOST'.freeze
      QUERY_STRING = 'QUERY_STRING'.freeze

      attr_reader :method, :host, :path, :ip, :query
      attr_reader :db, :elapsed
      attr_accessor :request_params

      
      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine, handler, env = nil )
        @engine = engine
        @log = @engine.log
        @request_params = RequestParams.new( @log )

        @handler = handler

        @env = env
        detect_env
      end


      # ---------------------------------------------------------------------
      #    Process Request
      # ---------------------------------------------------------------------

      #
      # Process the request and return a result.
      # 
      def process
        start_timer

        # Run the on_request script if there is one.
        @handler.server_obj.set_request_data self
        
        # Check authenticity token if it's given.
        if @request_params.check_authenticity_token( @engine )
          result, page_obj = @handler.handle self
        else
          # Render the error page.
          result = @handler.server_error_result
        end

        finish_timer

        # Run the on_response script if there is one.
        @handler.server_obj.set_response_data( self, result, page_obj )
        @handler.server_obj.run_on_response

        return result
      end

      
      # ---------------------------------------------------------------------
      #    ENV
      # ---------------------------------------------------------------------

      # 
      # Write the request information to the log.
      # 
      def detect_env
        req = Rack::Request.new( @env )

        @method = req.request_method
        @path = req.path
        @host = req.host_with_port
        @query = req.query_string

        @request_params.init_query_params( @query )
        @ip = req.ip
        @handler.server_obj.session.set_session_data_for_request( @env )

        @request_params.init_body_params( @env[ 'rack.input' ].read )
        @method = @request_params.get_body_method_override @method
      end


      # ---------------------------------------------------------------------
      #    Request timer
      # ---------------------------------------------------------------------

      # 
      # Keep track of the request start time.
      # 
      def start_timer
        @start = Time.now
        @engine.running_app.reset_db_time
      end
    
      # 
      # Write the request completion time to the log.
      # 
      def finish_timer
        @finish = Time.now
        @elapsed = ( ( @finish - @start ) * 1000.0 ).round(2)
        @db = @engine.running_app.db_time
        @log.info "*** Web request complete.  DB: #{@db} ms.  Elapsed time: #{@elapsed} ms"
      end
    

      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      # 
      # Write the request information to the log.
      # 
      def log
        @log.info "#{@method} #{@host}#{@path}"

        @request_params.log_params
      end

    end
  end
end
