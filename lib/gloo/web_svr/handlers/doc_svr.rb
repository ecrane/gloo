# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# Documentation server, request handler
# 

module Gloo
  module WebSvr
    class DocSvr < Gloo::WebSvr::Handler

      # ---------------------------------------------------------------------
      #    Process Request
      # ---------------------------------------------------------------------

      #
      # Process the request and return a result.
      # 
      def handle request
        # @request = request
        
        @log.debug 'Getting documentation index…'
        return Gloo::WebSvr::Response.html_response( @engine, page )
      end
          
    
      # ---------------------------------------------------------------------
      #    Helper functions
      # ---------------------------------------------------------------------

      def page
        dir = File.dirname( __FILE__ )        
        dir = File.dirname( dir )
        dir = File.dirname( dir )
        dir = File.dirname( dir )
        index_path = File.join( dir, 'doc', 'index.html.erb')
        index = File.read( index_path )

        params = {
          msg: 'Coming soon...'
        }
        render = ERB.new( index )
        contents =  render.result_with_hash( params )

        return contents
      end

    end
  end
end
