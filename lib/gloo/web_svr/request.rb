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
      
      attr_reader :method, :host, :path, :query

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
        @method = @env[ 'REQUEST_METHOD' ]
        @path = @env[ 'REQUEST_PATH' ]
        @host = @env[ 'HTTP_HOST' ]
        @query = @env[ 'QUERY_STRING' ]
      end


      # ---------------------------------------------------------------------
      #    Request timer
      # ---------------------------------------------------------------------

      # 
      # Keep track of the request start time.
      # 
      def start_timer
        @start = Time.now
      end
    
      # 
      # Write the request completion time to the log.
      # 
      def finish_timer
        @finish = Time.now
        @elapsed = ( ( @finish - @start ) * 1000.0 ).round(2)
        @log.info "Web request complete.  Elapsed time: #{@elapsed} ms"
      end
    

      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

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
