# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
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
      

      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine = nil, 
        code = Gloo::WebSvr::ResponseCode::SUCCESS, 
        type = HTML_TYPE, data = nil )
        
        @engine = engine
        @log = @engine.log if @engine

        @code = code
        @type = type
        @data = data
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
        # puts "Headers: #{headers}"
        # Rack::Utils.set_cookie_header!( headers, "_gloo_session_test", { value: "test", path: "/", http_only: 1, Secure: 1, expires: Time.now } )
        Rack::Utils.set_cookie_header!( headers, "_gloo_session_test", { value: "test", path: "/", http_only: true, Secure: true } )
        # puts "Headers after: #{headers}"

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
