# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that can make an HTTP GET request.
#
require 'net/http'
require 'uri'
require 'json'
require 'openssl'

module Gloo
  module Objs
    class HttpGet < Gloo::Core::Obj

      KEYWORD = 'http_get'.freeze
      KEYWORD_SHORT = 'get'.freeze
      URL = 'uri'.freeze
      DEFAULT_URL = 'https://web.site/'.freeze
      PARAMS = 'params'.freeze
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
        fac.create_string URL, DEFAULT_URL, self
        fac.create_can PARAMS, self
        fac.create_string RESULT, nil, self
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
        url = full_url_value
        @engine.log.debug url
        r = Gloo::Objs::HttpGet.invoke_request( url, skip_ssl_verify? )
        update_result r
      end

      # ---------------------------------------------------------------------
      #    Static functions
      # ---------------------------------------------------------------------

      #
      # Post the content to the endpoint.
      #
      def self.invoke_request( url, skip_ssl_verify = false )
        uri = URI( url )
        params = { use_ssl: uri.scheme == 'https' }

        params[ :verify_mode ] = ::OpenSSL::SSL::VERIFY_NONE if skip_ssl_verify

        Net::HTTP.start( uri.host, uri.port, params ) do |http|
          request = Net::HTTP::Get.new uri
          response = http.request request # Net::HTTPResponse object
          return response.body
        end
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Get the URI from the child object.
      # Returns nil if there is none.
      #
      def uri_value
        return find_child_value URL
      end

      #
      # Should we skip SSL verification during the request?
      #
      def skip_ssl_verify?
        return find_child_value( SKIP_SSL_VERIFY ) || false
      end

      #
      # Set the result of the API call.
      #
      def update_result( data )
        r = find_child_resolve_alias RESULT
        return unless r

        r.set_value data
      end

      #
      # Get the URL for the service including all URL params.
      #
      def full_url_value
        p = ''
        params = find_child_resolve_alias PARAMS
        params.children.each do |child|
          p << ( p.empty? ? '?' : '&' )

          child = Gloo::Objs::Alias.resolve_alias( @engine, child )

          # TODO: Quote URL params for safety
          p << "#{child.name}=#{child.value}"
        end
        return "#{uri_value}#{p}"
      end

      # ---------------------------------------------------------------------
      #    Object Documentation
      # ---------------------------------------------------------------------

      #
      # Get the object's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Perform an HTTP Get.',
          :children => [
            "uri (string) — Example: 'https://web.site/'. The URI for the HTTP Get request.",
            'params (container) — Collection of parameters for the HTTP Get.',
            'result (string) — The result of the request. Whatever was returned from the HTTP Get call.',
            'skip_ssl_verify (boolean) — Optional. Skip the SSL verification as part of the request.'
          ],
          :messages => [
            'run — Run the HTTP Get and update the result.'
          ],
          :examples => <<~EXAMPLES.strip
            g [http_get] :
              uri [string] : http://api.sunrise-sunset.org/json
              params [container] :
                lat [string] : 36.7201600
                lng [string] : -4.4203400
                date [string] : today
              result [string] :

            > run g
          EXAMPLES
        }
      end

    end
  end
end
