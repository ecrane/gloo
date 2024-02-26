# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A web page hosted in a gloo web server.
#

module Gloo
  module Objs
    class Page < Gloo::Core::Obj

      KEYWORD = 'page'.freeze
      KEYWORD_SHORT = 'page'.freeze

      # Page Title
      TITLE = 'title'.freeze

      # Events
      ON_RENDER = 'on_render'.freeze
      ON_RENDERED = 'on_rendered'.freeze

      # Parameters used during render.
      PARAMS = 'params'.freeze

      # Content
      HEAD = 'head'.freeze
      BODY = 'body'.freeze


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
        return super + [ 'render' ]
      end

      #
      # Get the expiration date for the certificate.
      #
      def msg_render
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
