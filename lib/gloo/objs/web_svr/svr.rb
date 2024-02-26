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
        fac.create_string TITLE, '', self

        fac.create_script ON_RENDER, '', self
        fac.create_script ON_RENDERED, '', self

        fac.create_can PARAMS, self
        fac.create_can HEAD, self
        fac.create_can BODY, self
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
        # return unless value
        # o = value
        # uri = URI( value )
        # response = Net::HTTP.start( uri.host, uri.port, :use_ssl => true )
        # cert = response.peer_cert
        # o = cert.not_after

        # @engine.heap.it.set_to o
        # return o
      end

      #
      # Stop the running web server.
      #
      def msg_stop
        # return unless value
        # o = value
        # uri = URI( value )
        # response = Net::HTTP.start( uri.host, uri.port, :use_ssl => true )
        # cert = response.peer_cert
        # o = cert.not_after

        # @engine.heap.it.set_to o
        # return o
      end

    end
  end
end
