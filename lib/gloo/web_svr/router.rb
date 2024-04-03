# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# A helper class for page routing.
# 

module Gloo
  module WebSvr
    class Router
      
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
      end


      # ---------------------------------------------------------------------
      #    Routing
      # ---------------------------------------------------------------------

      # 
      # Find and return the page for the given route.
      # 
      def page_for_route path
        # return nil if path == '/favicon.ico'

        @engine.log.debug "routing to #{path}"
        route_segments = path.split '/'
        route_segments.shift if route_segments.first == ''

        if route_segments.count == 0
          return @web_svr_obj.home_page
        else
          pages = @web_svr_obj.pages_container
          return nil unless pages

          return find_route_segment( route_segments, pages.children )
        end

        return nil
      end

      # 
      # Find the route segment in the object container.
      # 
      def find_route_segment segment_arr, objs
        this_segment = segment_arr.shift
        return nil if this_segment.nil?
        
        objs.each do |o|
          o = Gloo::Objs::Alias.resolve_alias( @engine, o )

          if o.name == this_segment
            if o.class == Gloo::Objs::Page
              @engine.log.debug "found page for route: #{o.pn}"
              return o
            elsif o.class == Gloo::Objs::FileHandle
              @engine.log.debug "found static file for route: #{o.pn}"
              return o
            else
              return nil unless o.child_count > 0

              return find_route_segment( segment_arr, o.children )
            end
          end
        end

        return nil 
      end

    end
  end
end
