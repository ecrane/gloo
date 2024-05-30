# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# A web Request for a page, action, or static resource.
#
# Kinds of Resources
#   Web Page
#   Action - does something and redirects to a page (or returns nothing)
#   API - returns JSON instead of HTML (but is that different from Web Page?)
#   Static Resource - File, PDF, Image, etc.
# 

module Gloo
  module WebSvr
    class Request

      REQUEST_METHOD = 'REQUEST_METHOD'.freeze
      REQUEST_PATH = 'REQUEST_PATH'.freeze
      HTTP_HOST = 'HTTP_HOST'.freeze
      QUERY_STRING = 'QUERY_STRING'.freeze

      attr_reader :method, :host, :path, :query
      attr_accessor :id

      
      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine, handler, env = nil )
        @engine = engine
        @log = @engine.log

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
        result = @handler.handle self
        finish_timer
        return result
      end

      # ---------------------------------------------------------------------
      #    ENV
      # ---------------------------------------------------------------------

      # 
      # Write the request information to the log.
      # 
      def detect_env
        @method = @env[ REQUEST_METHOD ]
        @path = @env[ REQUEST_PATH ]
        @host = @env[ HTTP_HOST ]
        @query = @env[ QUERY_STRING ]
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
        db = @engine.running_app.db_time
        @log.info "*** Web request complete.  DB: #{db} ms.  Elapsed time: #{@elapsed} ms"
      end
    

      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      #
      # Get the hash of query parameters.
      # 
      def query_params
        return {} unless @query
        return Rack::Utils.parse_query( @query )
      end

      # 
      # Write the request information to the log.
      # 
      def log
        @log.info "#{@method} #{@host}#{@path}"
        @log.info "Parameters: #{@query}"
      end

    end
  end
end
