# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# The Response for a web Request.
#

module Gloo
  module WebSvr
    class Response

      # 
      # SEE: https://stackoverflow.com/questions/23714383/what-are-all-the-possible-values-for-http-content-type-header#48704300
      #  for a list of content types.
      # 
      CONTENT_TYPE = 'Content-Type'.freeze
      TEXT_TYPE = 'text/plain'.freeze
      JSON_TYPE = 'application/json'.freeze
      HTML_TYPE = 'text/html'.freeze
            
      attr_reader :code, :type, :data
      attr_accessor :location
      

      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine = nil, 
        code = Gloo::WebSvr::ResponseCode::SUCCESS, 
        type = HTML_TYPE, 
        data = nil,
        assetCache = false )
        
        @engine = engine
        @log = @engine.log if @engine

        @code = code
        @type = type
        @data = data
        @assetCache = assetCache
        @location = nil
      end


      # ---------------------------------------------------------------------
      #    Static Helper Functions
      # ---------------------------------------------------------------------

      # 
      # Helper to create a successful JSON response with the given data.
      # 
      def self.json_response( engine, data, 
        code = Gloo::WebSvr::ResponseCode::SUCCESS )

        return Gloo::WebSvr::Response.new( engine, code, JSON_TYPE, data )
      end

      # 
      # Helper to create a successful text response with the given data.
      # 
      def self.text_response( engine, data, 
        code = Gloo::WebSvr::ResponseCode::SUCCESS )

        return Gloo::WebSvr::Response.new( engine, code, TEXT_TYPE, data )
      end

      # 
      # Helper to create a successful web response with the given data.
      # 
      def self.html_response( engine, data, 
        code = Gloo::WebSvr::ResponseCode::SUCCESS )

        return Gloo::WebSvr::Response.new( engine, code, HTML_TYPE, data )
      end

      # 
      # Helper to create a redirect response.
      # 
      def self.redirect_response( engine, target )
        code = Gloo::WebSvr::ResponseCode::FOUND
        data = <<~TEXT
        <head>
          <html>
            <body><a href="#{target}">target is here</a></body>
          </html>
        </head>
        TEXT

        response = Gloo::WebSvr::Response.new( engine, code, HTML_TYPE, data )
        response.location = target

        return response
      end


      # ---------------------------------------------------------------------
      #    Data Functions
      # ---------------------------------------------------------------------

      # 
      # Add content to the payload.
      # 
      def add content
        @data = '' if @data.nil?
        @data << content
      end

      # 
      # Get the headers for the response.
      # 
      def headers
        # 
        # TO DO: Add more cookie headers here.
        # 
        #  https://stackoverflow.com/questions/3295083/how-do-i-set-a-cookie-with-a-ruby-rack-middleware-component
        #   https://www.rubydoc.info/gems/rack/1.4.7/Rack/Session/Cookie
        #

        headers = { CONTENT_TYPE => @type }

        if @location
          headers[ 'Location' ] = @location
        end

        if @assetCache
          headers[ 'Cache-Control' ] = 'public, max-age=604800'
        end

        session = @engine&.running_app&.obj&.session
        headers = session.add_session_for_response( headers ) if session
  
        # Clear out session data after the response is prepared.
        @engine&.running_app&.obj&.reset_session_data

        return headers
      end

      # 
      # Get the final result that will be returned as the 
      # response to the web request.
      # 
      def result
        return [ @code, headers, @data ]
      end


      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      # 
      # Write the result information to the log.
      # 
      def log
        return unless @log

        @log.info "Response #{@code} #{@type}"
      end

    end
  end
end
