# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that can post JSON to a URI.
#
require 'net/http'
require 'uri'
require 'json'

module Gloo
  module Objs
    class HttpPost < Gloo::Core::Obj

      KEYWORD = 'http_post'.freeze
      KEYWORD_SHORT = 'post'.freeze
      URL = 'uri'.freeze
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
      # Get the URI from the child object.
      # Returns nil if there is none.
      #
      def uri_value
        uri = find_child URL
        return nil unless uri

        return uri.value
      end

      #
      # Get all the children of the body container and
      # convert to JSON that will be sent in the HTTP body.
      #
      def body_as_json
        h = {}

        body = find_child BODY
        body.children.each do |child|
          h[ child.name ] = child.value
        end

        return h.to_json
      end

      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      def add_children_on_create?
        return true
      end

      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      def add_default_children
        fac = $engine.factory
        fac.create( { :name => 'uri',
                      :type => 'string',
                      :value => 'https://web.site/',
                      :parent => self } )
        fac.create( { :name => 'body',
                      :type => 'container',
                      :value => nil,
                      :parent => self } )
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'run' ]
      end

      # Post the content to the endpoint.
      def msg_run
        uri = uri_value
        return unless uri

        use_ssl = uri.downcase.start_with?( 'https' )
        Gloo::Objs::HttpPost.post_json uri, body_as_json, use_ssl
      end

      # ---------------------------------------------------------------------
      #    Static functions
      # ---------------------------------------------------------------------

      # Post the content to the endpoint.
      def self.post_json( url, body, use_ssl = true )
        # Structure the request
        uri = URI.parse( url )
        request = Net::HTTP::Post.new( uri.path )
        request.content_type = 'application/json'
        request.body = body
        n = Net::HTTP.new( uri.host, uri.port )
        n.use_ssl = use_ssl

        # Send the payload to the endpoint.
        n.start { |http| http.request( request ) }
      end

    end
  end
end
