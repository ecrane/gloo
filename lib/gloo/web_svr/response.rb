# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# The Response for a web Request.
#

module Gloo
  module WebSvr
    class Response

      SUCCESS = 200

      CONTENT_TYPE = 'Content-Type'
      TEXT_TYPE = 'text/plain'
      HTML_TYPE = 'text/html'
      
      attr_reader :code, :type, :data
      

      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( code = SUCCESS, type = HTML_TYPE, data = nil )
        @code = code
        @type = type
        @data = data
      end


      # ---------------------------------------------------------------------
      #    Static Helper Functions
      # ---------------------------------------------------------------------


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
        return { CONTENT_TYPE => @type }
      end

      # 
      # Get the final result that will be returned as the 
      # response to the web request.
      # 
      def result
        return [ @code, headers, @data ]
      end

    end
  end
end
