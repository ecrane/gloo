# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that can send a message to a Teams webhook.
#
require 'net/http'
require 'uri'
require 'json'

module Gloo
  module Objs
    class Teams < GlooLang::Core::Obj

      KEYWORD = 'teams'.freeze
      KEYWORD_SHORT = 'team'.freeze
      URL = 'uri'.freeze
      DEFAULT_URL = 'https://outlook.office.com/webhook/...'.freeze
      MSG = 'message'.freeze
      TITLE = 'title'.freeze
      COLOR = 'color'.freeze
      DEFAULT_COLOR = '008000'.freeze

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

      # Get the color value.
      def color_value
        c = find_child COLOR
        return nil unless c

        return c.value
      end

      #
      # Get all the children of the body container and
      # convert to JSON that will be sent in the HTTP body.
      #
      def body_as_json
        h = { 'title' => find_child( TITLE ).value,
              'text' => find_child( MSG ).value }
        color = color_value
        h[ 'themeColor' ] = color if color
        return h.to_json
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
        fac.create_string TITLE, '', self
        fac.create_string COLOR, DEFAULT_COLOR, self
        fac.create_string MSG, '', self
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
      # Post the content to Microsoft Teams.
      #
      def msg_run
        uri = uri_value
        return unless uri

        Gloo::Objs::HttpPost.post_json uri, body_as_json
      end

    end
  end
end
