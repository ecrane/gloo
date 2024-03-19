# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# Base class for a request handler.
# Takes a request and does what is needed to create a response.
# This class is abstract and should not be used directly.
# It should be subclassed and that subclass used.
# 

module Gloo
  module WebSvr
    class Handler
      
      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine )
        @engine = engine
        @log = @engine.log
      end


      # ---------------------------------------------------------------------
      #    Process Request
      # ---------------------------------------------------------------------

      #
      # Process the request and return a result.
      # 
      def handle request
        err = 'HandlerBase should not be used.  Use the HandlerAppSvr or other subclass'
        @log.error err
        raise err
      end
    
    end
  end
end
