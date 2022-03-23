# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Show a CLI prompt and user selection from a list.
#

module Gloo
  module Objs
    class Select < GlooLang::Core::Obj

      KEYWORD = 'select'.freeze
      KEYWORD_SHORT = 'sel'.freeze
      PROMPT = 'prompt'.freeze
      OPTIONS = 'options'.freeze
      RESULT = 'result'.freeze

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
      # Get the prompt from the child object.
      # Returns nil if there is none.
      #
      def prompt_value
        o = find_child PROMPT
        return nil unless o

        return o.value
      end

      #
      # Get the list of options for selection.
      #
      def options
        o = find_child OPTIONS
        return [] unless o

        return o.children.map( &:name )
      end

      #
      # Get the value of the selected item.
      #
      def key_for_option( selected )
        o = find_child OPTIONS
        return nil unless o

        o.children.each do |c|
          return c.value if c.name == selected
        end

        return nil
      end

      #
      # Set the result of the system call.
      #
      def set_result( data )
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
        fac = @engine.factory
        fac.create_string PROMPT, '>', self
        fac.create_can OPTIONS, self
        fac.create_string RESULT, nil, self
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[run]
      end

      #
      # Show the prompt and get the user's selection.
      #
      def msg_run
        prompt = prompt_value
        return unless prompt

        per = Gloo::App::Settings.page_size
        result = @engine.platform.prompt.select( prompt, options, :per_page => per )
        set_result self.key_for_option( result )
      end

    end
  end
end
