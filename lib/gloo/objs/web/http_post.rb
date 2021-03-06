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
      RESULT = 'result'.freeze
      SKIP_SSL_VERIFY = 'skip_ssl_verify'.freeze

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
          child_val = Gloo::Objs::Alias.resolve_alias( child )
          h[ child.name ] = child_val.value
        end

        return h.to_json
      end

      #
      # Set the result of the API call.
      #
      def update_result( data )
        r = find_child RESULT
        return nil unless r

        r.set_value data
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
        fac = $engine.factory
        fac.create_string URL, 'https://web.site/', self
        fac.create_can BODY, self
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

      #
      # Post the content to the endpoint.
      #
      def msg_run
        uri = uri_value
        return unless uri

        $log.debug "posting to: #{uri}"
        body = self.body_as_json
        $log.debug "posting body: #{body}"
        data = Gloo::Objs::HttpPost.post_json( uri, body, skip_ssl_verify? )
        self.update_result data
      end

      # ---------------------------------------------------------------------
      #    Static functions
      # ---------------------------------------------------------------------

      #
      # Post the content to the endpoint.
      #
      def self.post_json( url, body, skip_ssl_verify = false )
        uri = URI( url )
        params = { use_ssl: uri.scheme == 'https' }
        params[ :verify_mode ] = ::OpenSSL::SSL::VERIFY_NONE if skip_ssl_verify

        Net::HTTP.start( uri.host, uri.port, params ) do |http|
          request = Net::HTTP::Post.new uri
          request.content_type = 'application/json'
          request.body = body

          result = http.request request # Net::HTTPResponse object
          $log.debug result.code
          $log.debug result.message
          return result.body
        end
      end

      # #
      # # Post the content to the endpoint.
      # #
      # def self.post_json_1( url, body, use_ssl = true )
      #   # Structure the request
      #   uri = URI.parse( url )
      #
      #   request = Net::HTTP::Post.new( uri.path )
      #   request.content_type = 'application/json'
      #   request.body = body
      #   n = Net::HTTP.new( uri.host, uri.port )
      #   n.use_ssl = use_ssl
      #
      #   # Send the payload to the endpoint.
      #   result = n.start { |http| http.request( request ) }
      #   $log.debug result.code
      #   $log.debug result.message
      #   return result.body
      # end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Should we skip SSL verification during the request?
      #
      def skip_ssl_verify?
        skip = find_child SKIP_SSL_VERIFY
        return false unless skip

        return skip.value
      end

    end
  end
end
