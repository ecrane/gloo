# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A helper class for to show routes for a running app.
# 

module Gloo
  module WebSvr
    module Routing
      class ShowRoutes

        SEGMENT_DIVIDER = '/'.freeze


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
        #    Show Routes
        # ---------------------------------------------------------------------

        # 
        # Show all available routes.
        # 
        def show page_container
          @log.debug "showing routes"

          @found_routes = []
          @log.debug "building route table"
          add_container_routes( page_container, SEGMENT_DIVIDER )

          show_table
        end

        #
        # Show the routes in the given container.
        # This is a recursive function travese the object tree.
        # 
        def add_container_routes can, route_path
          can.children.each do |obj|
            if obj.class == Gloo::Objs::Container
              add_container_routes obj, "#{route_path}#{obj.name}#{SEGMENT_DIVIDER}"
            elsif obj.class == Gloo::Objs::Page
              route = "#{route_path}#{obj.name}"
              @found_routes << [ obj.name, obj.pn, route, Gloo::WebSvr::WebMethod::GET ]

              # If the method is POST, add a route alias for the create.
              if obj.name.eql? ResourceRouter::POST_ROUTE
                @found_routes << [ '', '', route_path, Gloo::WebSvr::WebMethod::POST ]
              elsif obj.name.eql? ResourceRouter::UPDATE
                @found_routes << [ '', '', route_path, Gloo::WebSvr::WebMethod::PATCH ]
              elsif obj.name.eql? ResourceRouter::DELETE
                @found_routes << [ '', '', route_path, Gloo::WebSvr::WebMethod::DELETE ]
              end
            end
          end
        end


        # ---------------------------------------------------------------------
        #    Show Routes
        # ---------------------------------------------------------------------

        # 
        # Show the Routes title.
        # 
        def show_table
          puts Gloo::App::Platform::RETURN
          title = "Routes in Running Web App"
          @engine.platform.table.show headers, @found_routes, title
          puts Gloo::App::Platform::RETURN
        end

        # 
        # Get the table headers.
        # 
        def headers
          return [ 'Obj Name', 'Obj Path', 'Route', 'Method' ]
        end

      end
    end
  end
end
