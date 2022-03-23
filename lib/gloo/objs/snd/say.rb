# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Wrapper for the 'say something' function on the Mac.
#
require 'erb'

module Gloo
  module Objs
    class Say < GlooLang::Core::Obj

      KEYWORD = 'say'.freeze
      KEYWORD_SHORT = 'say'.freeze
      VOICE = 'voice'.freeze
      MSG = 'message'.freeze
      DEFAULT_MSG = 'talk to me'.freeze

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
      # Get the voice to use.
      #
      def voice_value
        v = find_child VOICE
        return nil unless v

        return v.value
      end

      #
      # Get the message to speak.
      #
      def msg_value
        o = find_child MSG
        return nil unless o

        return o.value
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
        fac.create_string VOICE, '', self
        fac.create_string MSG, DEFAULT_MSG, self
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
      # Have the computer 'speak' the message.
      #
      def msg_run
        v = voice_value.empty? ? '' : "-v '#{voice_value}'"
        cmd = "say #{v} '#{msg_value}'"
        system cmd
      end

    end
  end
end
