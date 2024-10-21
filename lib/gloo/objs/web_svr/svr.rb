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

      # ---------------------------------------------------------------------
      #    CONFIGURATION KEYS
      # ---------------------------------------------------------------------
      CONFIG = 'config'.freeze
      SCHEME = 'scheme'.freeze
      HTTP = 'http'.freeze
      HTTPS = 'https'.freeze
      HOST = 'host'.freeze
      PORT = 'port'.freeze
      SESSION_NAME = 'session_name'.freeze
      ENCRYPT_KEY = 'encryption_key'.freeze
      ENCRYPT_IV = 'encryption_iv'.freeze
      COOKIE_EXPIRES = 'cookie_expires'.freeze
      COOKIE_PATH = 'cookie_path'.freeze
      DEFAULT_COOKIE_PATH = '/'.freeze

      # SSL Configuration
      SSL_CERT = 'ssl_cert'.freeze
      SSL_KEY = 'ssl_key'.freeze

      # ---------------------------------------------------------------------
      #    OTHER KEYS
      # ---------------------------------------------------------------------

      # Events
      ON_START = 'on_start'.freeze
      ON_STOP = 'on_stop'.freeze
      ON_REQUEST = 'on_request'.freeze
      ON_RESPONSE = 'on_response'.freeze
      RESQUEST_DATA = 'request_data'.freeze
      METHOD = 'method'.freeze
      PATH = 'path'.freeze
      QUERY = 'query'.freeze
      IP = 'ip'.freeze
      RESPONSE_DATA = 'response_data'.freeze
      TYPE = 'type'.freeze
      CODE = 'code'.freeze
      ELAPSED = 'elapsed'.freeze
      DB = 'db'.freeze
      PAGE = 'page'.freeze

      # Container with pages in the web app.
      PAGES = 'pages'.freeze

      # Default layout for pages.
      LAYOUT = 'layout'.freeze

      # Alias to the home and error pages
      HOME = 'home'.freeze
      ERR_PAGE = 'error'.freeze

      # Session
      SESSION = 'session'.freeze


      # Messages
      SERVER_NOT_RUNNING = 'The web server is not running!'.freeze

      # 
      # Should the current request be redirected?
      # If the redirect is set, then use that page instead
      # of the one requested.
      # 
      attr_accessor :redirect, :router, :asset, :embedded_renderer
      attr_accessor :session

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
      # Get the default layout for the app.
      # 
      def default_page_layout
        o = find_child LAYOUT
        return nil unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o
      end


      # ---------------------------------------------------------------------
      #    Configuration
      # ---------------------------------------------------------------------

      #
      # Get the Scheme (http or https) from the child object.
      # Returns nil if there is none.
      #
      def scheme_value
        config = find_child CONFIG
        scheme = config.find_child SCHEME
        return nil unless scheme

        return scheme.value
      end
      
      #
      # Get the host from the child object.
      # Returns nil if there is none.
      #
      def host_value
        config = find_child CONFIG
        host = config.find_child HOST
        return nil unless host

        return host.value
      end

      #
      # Get the port from the child object.
      # Returns nil if there is none.
      #
      def port_value
        config = find_child CONFIG
        port = config.find_child PORT
        return nil unless port

        return port.value
      end

      # 
      # Is this server configured to use a session?
      # It is if theere is a non-empty session name.
      # 
      def use_session?
        return ! session_name.blank?
      end

      # 
      # Get the session cookie name.
      # 
      def session_name
        config = find_child CONFIG
        session_name = config.find_child SESSION_NAME
        return nil unless session_name

        name = session_name.value
        return nil if name.blank?

        return name
      end

      # 
      # Get the key for the encryption cipher.
      # 
      def encryption_key
        config = find_child CONFIG
        o = config.find_child ENCRYPT_KEY
        return nil unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o.value
      end

      # 
      # Get the initialization vector for the cipher.
      # 
      def encryption_iv
        config = find_child CONFIG
        o = config.find_child ENCRYPT_IV
        return nil unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o.value
      end

      # 
      # Get the path for the session cookie.
      # If not specified, use the root path.
      # 
      def session_cookie_path
        config = find_child CONFIG
        o = config.find_child COOKIE_PATH
        if o
          return o.value
        else
          return DEFAULT_COOKIE_PATH
        end
      end

      # 
      # Get the expiration time for the session cookie.
      # If not specified, use one week from now.
      # 
      def session_cookie_expires
        config = find_child CONFIG
        o = config.find_child COOKIE_EXPIRES
        if o
          dt = Chronic.parse( o.value )
          return dt
        else
          return 1.week.from_now
        end
      end

      # 
      # Should the session cookie be secure?
      # Get the value from the scheme settings/config.
      # 
      def session_cookie_secure
        return scheme_value.downcase == HTTPS
      end


      # ---------------------------------------------------------------------
      #    Session
      # ---------------------------------------------------------------------

      # 
      # Get the session container object.
      # If there is none, one will be created.
      # 
      def session_container
        o = find_child SESSION

        unless o
          o = add_session_container
        end

        return o
      end

      # 
      # Add the session container because it is missing.
      # 
      def add_session_container
        fac = @engine.factory
        return fac.create_can SESSION, self
      end

      # 
      # Get the data from the session container.
      # Data will be in the form of a hash ( key => value ).
      # 
      def get_session_data
        data = {}

        session_container.children.each do |session_var|
          key = session_var.name
          value = session_var.value
          data[ key ] = value
        end

        return data
      end

      # 
      # Get the session child object with the given value.
      # Create the child if it does not exist.
      # 
      def set_session_var( key, value )
        child_obj = session_container.find_child( key )
        unless child_obj
          fac = @engine.factory
          child_obj = fac.create_string key, value, session_container
        end
        child_obj.value = value
      end

      # 
      # Clear out all session data.
      # Important to do this after the response is sent
      # to avoid holding on to data that is no longer needed.
      # 
      def clear_session_data
        session_container.children.each do |session_var|
          session_var.value = ''
        end
      end


      # ---------------------------------------------------------------------
      #    SSL
      # ---------------------------------------------------------------------

      # 
      # Is SSL configured for this server?
      # True if the Cert and Key are both present.
      # 
      def use_ssl?
        return ssl_cert && ssl_key
      end

      #
      # Get the SSL certificate from the child object.
      # Returns nil if there is none.
      #
      def ssl_cert
        cert = find_child SSL_CERT
        return nil unless cert

        cert = Gloo::Objs::Alias.resolve_alias( @engine, cert )
        return cert
      end

      #
      # Get the SSL key from the child object.
      # Returns nil if there is none.
      #
      def ssl_key
        key = find_child SSL_KEY
        return nil unless key

        key = Gloo::Objs::Alias.resolve_alias( @engine, key )
        return key
      end

      # 
      # Get the SSL configuration for the server.
      # 
      def ssl_config
        return nil unless use_ssl?

        return {
          :private_key_file => ssl_key.value,
          :cert_chain_file => ssl_cert.value,
          :verify_peer => false,
        }
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

        # Configuration
        config = fac.create_can CONFIG, self
        fac.create_string SCHEME, HTTP, config
        fac.create_string HOST, 'localhost', config
        fac.create_string PORT, '8080', config

        fac.create_script ON_START, '', self
        fac.create_script ON_STOP, '', self

        fac.create_alias LAYOUT, nil, self
        fac.create_alias HOME, nil, self
        fac.create_alias ERR_PAGE, nil, self

        fac.create_can PAGES, self
      end


      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'start', 'stop', 'routes' ]
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
          @engine.err SERVER_NOT_RUNNING
        end
      end

      # 
      # Helper message to show all routes in the running server.
      # 
      def msg_routes
        if @router
          @router.show_routes
        else
          @engine.err SERVER_NOT_RUNNING
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
        @web_server = Gloo::WebSvr::Server.new( @engine, handler, config, ssl_config )
        @web_server.start

        @router = Gloo::WebSvr::Routing::Router.new( @engine, self )
        @router.add_page_routes

        @asset = Gloo::WebSvr::Asset.new( @engine, self )
        @asset.add_asset_routes

        @embedded_renderer = Gloo::WebSvr::EmbeddedRenderer.new( @engine, self )

        @session = Gloo::WebSvr::Session.new( @engine, self )
        
        run_on_start
        @engine.log.info "Web server started and listening…"
      end

      # 
      # Stop the running web server.
      # 
      def stop
        @engine.log.info "Stopping web server…"

        # Last chance to clear out session data.
        clear_session_data

        @web_server.stop
        @web_server = nil
        @router = nil

        run_on_stop
        @engine.log.info "Web server stopped…"
      end


      # ---------------------------------------------------------------------
      #    On Events - Scripts
      # ---------------------------------------------------------------------

      #
      # Run the on start script if there is one.
      #
      def run_on_start
        o = find_child ON_START
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end

      #
      # Run the on stop script if there is one.
      #
      def run_on_stop
        o = find_child ON_STOP
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end

      #
      # Run the on request script if there is one.
      #
      def run_on_request
        o = find_child ON_REQUEST
        return unless o
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end

      #
      # Run the on response script if there is one.
      #
      def run_on_response
        o = find_child ON_RESPONSE
        return unless o
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end

      # 
      # Set up the request data for the page load.
      # This is done before the on_request event is fired.
      # 
      def set_request_data( request )
        data = find_child RESQUEST_DATA
        return unless data
        data = Gloo::Objs::Alias.resolve_alias( @engine, data )

        data.find_child( METHOD )&.set_value( request.method )
        data.find_child( HOST )&.set_value( request.host )
        data.find_child( PATH )&.set_value( request.path )
        data.find_child( QUERY )&.set_value( request.query )
        data.find_child( IP )&.set_value( request.ip )
      end

      # 
      # Set up the response data for the page load.
      # This is done after the page is rendered and before
      # the on_response event is fired.
      # 
      def set_response_data( request, response, page_obj=nil )
        data = find_child RESPONSE_DATA
        return unless data
        data = Gloo::Objs::Alias.resolve_alias( @engine, data )

        data.find_child( ELAPSED )&.set_value( request.elapsed )
        data.find_child( DB )&.set_value( request.db )
        data.find_child( TYPE )&.set_value( response.type )
        data.find_child( CODE )&.set_value( response.code )

        if page_obj
          data.find_child( PAGE )&.set_value( page_obj.pn ) 
        end
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
