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

      # Default layout for pages.
      LAYOUT = 'layout'.freeze

      # Alias to the home and error pages
      HOME = 'home'.freeze
      ERR_PAGE = 'error'.freeze


      # Messages
      SERVER_NOT_RUNNING = 'The web server is not running and cannot be stopped'.freeze

      # 
      # Should the current request be redirected?
      # If the redirect is set, then use that page instead
      # of the one requested.
      # 
      attr_accessor :redirect, :router, :asset, :embedded_renderer

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


      # 
      # Get the default layout for the app.
      # 
      def default_page_layout
        o = find_child LAYOUT
        return nil unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o
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
        @engine.start_running_app( self )
        # The running app will call the start function (below)
      end

      #
      # Stop the running web server.
      #
      def msg_stop
        if @web_server
          @engine.stop_running_app
          # The running app will call the stop function (below)
        else
          @engine.log.error SERVER_NOT_RUNNING
        end
      end

      # ---------------------------------------------------------------------
      #    Start and Stop Events
      #    Might come from messages or from other application events.
      #    RunningApp fires these events.
      # ---------------------------------------------------------------------

      # 
      # Start running the web server.
      # 
      def start
        config = Gloo::WebSvr::Config.new( scheme_value, host_value, port_value )
        @engine.log.info "Web Server URL: #{config.base_url}"

        handler = Gloo::WebSvr::Handler.new( @engine, self )
        @web_server = Gloo::WebSvr::Server.new( @engine, handler, config )
        @web_server.start

        @router = Gloo::WebSvr::Router.new( @engine, self )
        @router.add_page_routes

        @asset = Gloo::WebSvr::Asset.new( @engine, self )
        @asset.add_asset_routes

        @embedded_renderer = Gloo::WebSvr::EmbeddedRenderer.new( @engine, self )

        run_on_start
        @engine.log.info "Web server started and listening…"
      end

      # 
      # Stop the running web server.
      # 
      def stop
        @engine.log.info "Stopping web server…"
        @web_server.stop
        @web_server = nil

        run_on_stop
        @engine.log.info "Web server stopped…"
      end


      # ---------------------------------------------------------------------
      #    On Events - Scripts
      # ---------------------------------------------------------------------

      #
      # Run the on render script if there is one.
      #
      def run_on_start
        o = find_child ON_START
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end

      #
      # Run the on rendered script if there is one.
      #
      def run_on_stop
        o = find_child ON_STOP
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end


      # ---------------------------------------------------------------------
      #    Pages and standard elements.
      # ---------------------------------------------------------------------

      # 
      # Get the pages container.
      # 
      def pages_container
        return find_child PAGES
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

      # 
      # Get the application error page.
      # 
      def err_page
        o = find_child ERR_PAGE
        return nil unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o
      end

      # 
      # Get the default layout for pages.
      # 
      def default_layout
        o = find_child LAYOUT
        return nil unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o
      end

    end
  end
end
