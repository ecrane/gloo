# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Configuration for a gloo web server.
#

module Gloo
  module WebSvr
    class Config

      SCHEME_SEPARATOR = '://'
      HTTP = 'http'
      HTTPS = 'https'
      LOCALHOST = 'localhost'
      PORT_DEFAULT = '8080'
      
      attr_reader :scheme, :host, :port
      

      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( scheme = HTTP, host = LOCALHOST, port = PORT_DEFAULT )
        @scheme = scheme
        @host = host
        @port = port
      end


      # ---------------------------------------------------------------------
      #    Static Helper Functions
      # ---------------------------------------------------------------------


      # ---------------------------------------------------------------------
      #    Helper Functions
      # ---------------------------------------------------------------------

      # 
      # The base url, including scheme, host and port.
      # 
      def base_url
        url = "#{self.scheme}#{SCHEME_SEPARATOR}#{self.host}"
        unless self.port.blank? 
          url << ":#{self.port}"
        end
        return url
      end

    end
  end
end
