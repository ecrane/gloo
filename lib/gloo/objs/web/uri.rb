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

        Gloo::Objs::Uri.open_url value, @engine
      end


      # ---------------------------------------------------------------------
      #    Helper function to open a URL
      # ---------------------------------------------------------------------

      # 
      # Open the given URL with platform command.
      # 
      # NOTE that this was using "cmd = Gloo::Core::GlooSystem.open_for_platform"
      # but refactored because on windows the command is more complex.
      # 
      def self.open_url( url, engine=nil )
        case 
        when OS.windows?
          system( "powershell", "-Command", "Start-Process", url )
        when OS.mac?
          `open "#{url}"`
        when OS.linux?
          if Gloo::Core::GlooSystem.wsl?
            `explorer.exe "#{url}"`
          else
            `xdg-open "#{url}"`
          end
        else
          engine.log.warn 'Opening URL not supported on this platform.' if engine
        end
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
          :description => 'A URI or URL.',
          :messages => [
            'open — Open the URL in the default browser.',
            'get_scheme — Get the URI scheme; example: http.',
            'get_host — Get the URI host; example: google.com.',
            'get_path — Get the URI resource path; example: /post.',
            'get_query — Get the URI query parameters; example: id=121.',
            'get_fragment — Get the URI fragment.',
            'get_cert_expires — Get the web site\'s certificate expiration date.'
          ],
          :examples => <<~EXAMPLES.strip
            url [can] :
              on_load [script] :
                tell url.u to get_scheme
                show "scheme: " + it

                tell url.u to get_host
                show "host: " + it

                tell url.u to get_path
                show "path: " + it

                show "opening URL: " + url.u
                tell url.u to open
              u [uri] : https://my.url/path/1234
          EXAMPLES
        }
      end

    end
  end
end
