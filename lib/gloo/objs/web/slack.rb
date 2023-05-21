# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that can send a message to a slack channel.
#
require 'net/http'
require 'uri'
require 'json'

module Gloo
  module Objs
    class Slack < GlooLang::Core::Obj

      KEYWORD = 'slack'.freeze
      KEYWORD_SHORT = 'slack'.freeze
      URL = 'uri'.freeze
      MSG = 'message'.freeze
      USER = 'username'.freeze
      CHANNEL = 'channel'.freeze
      ICON = 'icon_emoji'.freeze

      ATTACHMENT = 'attachment'.freeze
      TITLE = 'title'.freeze
      TEXT = 'text'.freeze

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
      # Get the URI from the child object.
      # Returns nil if there is none.
      #
      def attachment_value
        o = find_child ATTACHMENT
        return nil unless o

        title = o.find_child TITLE
        text = o.find_child TEXT
        return [ { 'title' => title.value,
                   'text' => text.value } ]
      end

      #
      # Get all the children of the body container and
      # convert to JSON that will be sent in the HTTP body.
      #
      def body_as_json
        h = { 'text' => find_child( MSG ).value,
              'username' => find_child( USER ).value,
              'channel' => find_child( CHANNEL ).value,
              'icon_emoji' => find_child( ICON ).value }

        o = attachment_value
        h[ 'attachments' ] = o if o
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
        fac.create_string URL, 'https://hooks.slack.com/services/...', self
        fac.create_string MSG, 'textual message', self
        fac.create_string USER, 'Slack Bot', self
        fac.create_string CHANNEL, 'general', self
        fac.create_string ICON, ':ghost:', self
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
      # Post the content to the Slack channel.
      #
      def msg_run
        uri = uri_value
        return unless uri

        Gloo::Objs::HttpPost.post_json uri, body_as_json
      end

    end
  end
end
