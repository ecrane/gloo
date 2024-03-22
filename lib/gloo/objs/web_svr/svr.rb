# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A web web server running inside gloo.
#

module Gloo
  module Objs
    class Svr < Gloo::Core::Obj

      KEYWORD = 'server'.freeze
      KEYWORD_SHORT = 'svr'.freeze

      # Configuration
      SCHEME = 'scheme'.freeze      
      HOST = 'host'.freeze
      PORT = 'port'.freeze

      # Events
      ON_START = 'on_start'.freeze
      ON_STOP = 'on_stop'.freeze

      # Container with pages in the web app.
      PAGES = 'pages'.freeze

      # Alias to the home page
      HOME = 'home'.freeze

      # Messages
      SERVER_NOT_RUNNING = 'The web server is not running and cannot be stopped'.freeze

      # 
      # Should the current request be redirected?
      # If the redirect is set, then use that page instead
      # of the one requested.
      # 
      attr_accessor :redirect

      #
      # The name of the object type.
      #
      def self.typename
        return KEYWORD
      end

      #
      # The short name of the object type.
      #
      def self.short_typename
        return KEYWORD_SHORT
      end

      #
      # Set the value with any necessary type conversions.
      #
      def set_value( new_value )
        self.value = new_value.to_s
      end

      #
      # Does this object support multi-line values?
      # Initially only true for scripts.
      #
      def multiline_value?
        return false
      end

      #
      # Get the Scheme (http or https) from the child object.
      # Returns nil if there is none.
      #
      def scheme_value
        scheme = find_child SCHEME
        return nil unless scheme

        return scheme.value
      end
      
      #
      # Get the host from the child object.
      # Returns nil if there is none.
      #
      def host_value
        host = find_child HOST
        return nil unless host

        return host.value
      end

      #
      # Get the port from the child object.
      # Returns nil if there is none.
      #
      def port_value
        port = find_child PORT
        return nil unless port

        return port.value
      end


      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      #
      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      #
      def add_children_on_create?
        return true
      end

      #
      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      #
      def add_default_children
        fac = @engine.factory

        fac.create_string SCHEME, 'http', self
        fac.create_string HOST, 'localhost', self
        fac.create_string PORT, '8080', self

        fac.create_script ON_START, '', self
        fac.create_script ON_STOP, '', self

        fac.create_can PAGES, self
        fac.create_can HOME, self
      end


      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'start', 'stop' ]
      end

      #
      # Start the gloo web server.
      #
      def msg_start
        @engine.log.debug "Starting web server…"
        # @engine.log.quiet = true

        # Set running app to this object.
        @engine.running_app = self

        config = Gloo::WebSvr::Config.new( scheme_value, host_value, port_value )
        @engine.log.debug "Web Server URL: #{config.base_url}"

        handler = Gloo::WebSvr::Handler.new( @engine, self )
        @web_server = Gloo::WebSvr::Server.new( @engine, handler, config )
        @web_server.start
        @engine.log.debug "Web server started…"
      end

      #
      # Stop the running web server.
      #
      def msg_stop
        if @web_server
          @engine.log.debug "Stopping web server…"
          @web_server.stop
          @web_server = nil

          # Clear running app.
          @engine.running_app = nil

          @engine.log.debug "Web server stopped…"
        else
          @engine.log.error SERVER_NOT_RUNNING
        end
      end

      # ---------------------------------------------------------------------
      #    Routing
      # ---------------------------------------------------------------------

      # 
      # Find and return the page for the given route.
      # 
      def page_for_route path
        return nil if path == '/favicon.ico'

        @engine.log.debug "routing to #{path}"
        route_segments = path.split '/'
        route_segments.shift if route_segments.first == ''

        if route_segments.count == 0
          return home_page
        else
          pages = find_child PAGES
          return nil unless pages

          return find_route_segment( route_segments, pages.children )
        end

        # TODO: return error page
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
            if o.class == Page
              @engine.log.debug "found page for route: #{o.pn}"
              return o
            else
              return nil unless o.child_count > 0

              return find_route_segment( segment_arr, o.children )
            end
          end
        end

        return nil # objs.first
      end

      # 
      # Get the home page, the root/default route.
      # 
      def home_page
        o = find_child HOME
        return nil unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o
      end


    end
  end
end
