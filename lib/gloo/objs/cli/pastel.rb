# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Show colorized output with the pastel gem.
#
require 'pastel'

module Gloo
  module Objs
    class Pastel < GlooLang::Core::Obj

      KEYWORD = 'pastel'.freeze
      KEYWORD_SHORT = 'pastel'.freeze
      TEXT = 'text'.freeze
      COLOR = 'color'.freeze

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
      # Get the text from the child object.
      #
      def text_value
        o = find_child TEXT
        return '' unless o

        return o.value
      end

      #
      # Get the color from the child object.
      #
      def color_value
        o = find_child COLOR
        return '' unless o

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
        fac = $engine.factory
        fac.create_string TEXT, '', self
        fac.create_string COLOR, '', self
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[show]
      end

      #
      # Show the banner bar
      #
      def msg_show
        pastel = ::Pastel.new
        c = self.color_value.split( ' ' ).map( &:to_sym )
        puts pastel.decorate( self.text_value, *c )
      end

    end
  end
end
