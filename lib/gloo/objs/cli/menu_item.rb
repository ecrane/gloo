# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A CLI menu item.  One element in a CLI menu.
#

module Gloo
  module Objs
    class MenuItem < GlooLang::Core::Obj

      KEYWORD = 'menu_item'.freeze
      KEYWORD_SHORT = 'mitem'.freeze
      SHORTCUT = 'shortcut'.freeze
      DESCRIPTION = 'description'.freeze
      DO = 'do'.freeze

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
      # Get the value of the menu item shortcut.
      # Returns nil if there is none.
      #
      def shortcut_value
        o = find_child SHORTCUT
        return self.name unless o

        return o.value
      end

      #
      # Get the action's description.
      # Returns nil if there is none.
      #
      def description_value
        o = find_child DESCRIPTION
        return self.value unless o

        return o.value
      end

      #
      # Get the action's script.
      # Returns nil if there is none.
      #
      def do_script
        return find_child DO
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
        fac.create_string SHORTCUT, '', self
        fac.create_string DESCRIPTION, '', self
        fac.create_script DO, '', self
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super
      end

    end
  end
end
