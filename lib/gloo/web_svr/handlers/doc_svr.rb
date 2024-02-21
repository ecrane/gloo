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
        contents = <<CONTENTS
         <html>
          <head>
            <title> Gloo Doc </title>
          </head>
          <body>
            <h1> Gloo Documentation </h1>

            <p> Coming soon... </p>

            <p> <em> #{Time.now} </em> </p>
          </body>
        </html>
CONTENTS

        return contents
      end

    end
  end
end
