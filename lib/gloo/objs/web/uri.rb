# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A URI (URL).
#
require 'uri'
require 'net/http'
require 'openssl'

module Gloo
  module Objs
    class Uri < Gloo::Core::Obj

      KEYWORD = 'uri'.freeze
      KEYWORD_SHORT = 'url'.freeze

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
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        basic = %w[open]
        gets = %w[get_scheme get_host get_path]
        more = %w[get_query get_fragment get_cert_expires]
        return super + basic + gets + more
      end

      #
      # Get the expiration date for the certificate.
      #
      def msg_get_cert_expires
        return unless value
        o = value
        uri = URI( value )
        response = Net::HTTP.start( uri.host, uri.port, :use_ssl => true )
        cert = response.peer_cert
        o = cert.not_after

        @engine.heap.it.set_to o
        return o
      end

      #
      # Get the URI fragment that comes after the '#'
      # in the URL.  Might be used to scroll down in the page.
      #
      def msg_get_fragment
        return unless value

        o = URI( value ).fragment
        @engine.heap.it.set_to o
        return o
      end

      #
      # Get the URI query parameters.
      # Example:  id=121
      #
      def msg_get_query
        return unless value

        o = URI( value ).query
        @engine.heap.it.set_to o
        return o
      end

      #
      # Get the URI path.
      # Example:  /posts
      #
      def msg_get_path
        return unless value

        o = URI( value ).path
        @engine.heap.it.set_to o
        return o
      end

      #
      # Get the URI host.
      # Example:  google.com
      #
      def msg_get_host
        return unless value

        o = URI( value ).host
        @engine.heap.it.set_to o
        return o
      end

      #
      # Get the URI Scheme.
      # Example:  http
      #
      def msg_get_scheme
        return unless value

        o = URI( value ).scheme
        @engine.heap.it.set_to o
        return o
      end

      #
      # Open the URI in the default browser.
      #
      def msg_open
        return unless value

        cmd = Gloo::Core::GlooSystem.open_for_platform
        cmd_with_param = "#{cmd} \"#{value}\""

        if OS.mac?
          `#{cmd_with_param}`
        else
          exec cmd_with_param
        end
      end

    end
  end
end
