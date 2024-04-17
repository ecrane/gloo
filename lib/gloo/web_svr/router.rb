# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# A helper class for page routing.
# 

module Gloo
  module WebSvr
    class Router
      
      INDEX = 'index'.freeze
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
      end


      # ---------------------------------------------------------------------
      #    Routing
      # ---------------------------------------------------------------------

      # 
      # Find and return the page for the given route.
      # 
      def page_for_route path
        @engine.log.debug "routing to #{path}"
        detect_segments path

        return @web_svr_obj.home_page if is_root_path?

        pages = @web_svr_obj.pages_container
        return find_route_segment( pages.children ) if pages

        return nil
      end


      
      # ---------------------------------------------------------------------
      #    Helper funcions
      # ---------------------------------------------------------------------

      # 
      # Find the route segment in the object container.
      # 
      def find_route_segment objs
        this_segment = next_segment

        this_segment = INDEX if this_segment.blank?

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

        return @route_segments
      end

    end
  end
end
