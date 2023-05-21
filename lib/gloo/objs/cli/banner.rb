# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Show a large-text banner.
#
require 'tty-font'
require 'pastel'

module Gloo
  module Objs
    class Banner < Gloo::Core::Obj

      KEYWORD = 'banner'.freeze
      KEYWORD_SHORT = 'ban'.freeze
      TEXT = 'text'.freeze
      STYLE = 'style'.freeze
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
      # Get the banner text from the child object.
      #
      def text_value
        o = find_child TEXT
        return '' unless o

        return o.value
      end

      #
      # Get the banner style from the child object.
      #
      def style_value
        o = find_child STYLE
        return '' unless o

        return o.value
      end

      #
      # Get the banner color from the child object.
      #
      def color_value
        o = find_child COLOR
        return '' unless o

        return o.value
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
        fac = @engine.factory
        fac.create_string TEXT, '', self
        fac.create_string STYLE, '', self
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
        font = TTY::Font.new self.style_value
        t = font.write( self.text_value )
        pastel = ::Pastel.new
        c = self.color_value.split( ' ' ).map( &:to_sym )
        puts pastel.decorate( t, *c )
      end

    end
  end
end
