# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A helper class for page routing.
# 
# require 'tty-table'

module Gloo
  module WebSvr
    module Routing
      class Router
        
        PAGE_CONTAINER = 'page'.freeze
        SEGMENT_DIVIDER = '/'.freeze

        attr_reader :route_segments


        # ---------------------------------------------------------------------
        #    Initialization
        # ---------------------------------------------------------------------

        #
        # Set up the web server.
        #
        def initialize( engine, web_svr_obj )
          @engine = engine
          @log = @engine.log

          @web_svr_obj = web_svr_obj
          @show_routes = ShowRoutes.new( @engine )
        end


        # ---------------------------------------------------------------------
        #    Routing
        # ---------------------------------------------------------------------

        # 
        # Find and return the page for the given route.
        # 
        def page_for_route( path, method )
          @log.info "routing to #{path} for method #{method}"
          @method = method
          
          detect_segments path

          return @web_svr_obj.home_page if is_root_path?

          pages = @web_svr_obj.pages_container
          if pages
            # If the method is POST and the last segment is NOT 'create',
            # we'll add create to the route segments.
            if Gloo::WebSvr::Routing::ResourceRouter.is_implicit_create?( method, @route_segments.last )
              @route_segments << Gloo::WebSvr::Routing::ResourceRouter::POST_ROUTE
              page = find_route_segment( pages.children )
              return [ page, @id ] if page

              # We didn't find the page, so remove the last segment and try again 
              # posting to the resource.
              @route_segments.pop
            end

            page = find_route_segment( pages.children ) 
            return [ page, @id ] if page
          end

          return nil
        end


        # ---------------------------------------------------------------------
        #    Dynamic Add Page Routes
        # ---------------------------------------------------------------------

        # 
        # Get the root level page container.
        #
        def page_container
          pn = Gloo::Core::Pn.new( @engine, PAGE_CONTAINER )
          return pn.resolve
        end

        # 
        # Add all page routes to the web server pages (routes).
        # 
        def add_page_routes
          can = page_container
          return unless can

          @log.debug 'Adding page routes to web server…'
          @factory = @engine.factory

          add_pages can, @web_svr_obj.pages_container
        end

        #
        # Add the pages to the web server pages.
        # This is a recursive function that will add all
        # pages in the folder and subfolders.
        #
        def add_pages can, parent
          # for each file in the page container
          # create a page object and add it to the routes
          can.children.each do |obj|
            if obj.class == Gloo::Objs::Container
              child_can = parent.find_add_child( obj.name, 'container' )
              add_pages( obj, child_can )
            elsif obj.class == Gloo::Objs::Page
              add_route_alias( parent, obj.name, obj.pn )
            end
          end
        end

        # 
        # Add route alias to the page.
        # 
        def add_route_alias( parent, name, pn )
          name = name.gsub( '.', '_' )

          # First make sure the child doesn't already exist.
          child = parent.find_child( name )
          return if child

          @factory.create_alias( name, pn, parent )
        end

        
        # ---------------------------------------------------------------------
        #    Helper funcions
        # ---------------------------------------------------------------------

        # 
        # Show the routes in the running app.
        # This uses the ShowRoutes helper class.
        #
        def show_routes
          @show_routes.show page_container
        end

        # 
        # Find the route segment in the object container.
        # 
        def find_route_segment objs
          this_segment = next_segment

          if this_segment.blank? # && Gloo::WebSvr::WebMethod.is_post?( @method )
            this_segment = Gloo::WebSvr::Routing::ResourceRouter::INDEX 
          end

          objs.each do |o|
            o = Gloo::Objs::Alias.resolve_alias( @engine, o )

            if o.name == this_segment
              if o.class == Gloo::Objs::Page
                @log.debug "found page for route: #{o.pn}"
                return o
              elsif o.class == Gloo::Objs::FileHandle
                @log.debug "found static file for route: #{o.pn}"
                return o
              else
                return nil unless o.child_count > 0

                return find_route_segment( o.children )
              end
            end
          end

          return nil 
        end

        # 
        # Get the next segment in the route.
        # 
        def next_segment
          this_segment = @route_segments.shift
          return nil if this_segment.nil?

          # A URL might include a dot in a name, but we can't do that
          # because dot is a reserve path thing. So we replace it with
          # an underscore.
          this_segment = this_segment.gsub( '.', '_' )

          return this_segment
        end

        # 
        # Is this the root path?
        def is_root_path?
          return @route_segments.count == 0
        end

        # 
        # Create a list of path segments.
        # 
        def detect_segments path
          # Split the path into segments.
          @route_segments = path.split SEGMENT_DIVIDER

          # Remove the first segment if it is empty.
          @route_segments.shift if @route_segments.first.blank?

          @route_segments.each do |seg|
            if seg.to_i.to_s == seg
              @id = seg.to_i
              @log.info "found id for route: #{@id}"
              @route_segments.delete seg
              @route_segments << ResourceRouter.segment_for_method( @method )
            end
          end

          return @route_segments
        end

      end
    end
  end
end
