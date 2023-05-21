# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# List out an object and it's children.
#

module GlooLang
  module Verbs
    class List < GlooLang::Core::Verb

      KEYWORD = 'list'.freeze
      KEYWORD_SHORT = '.'.freeze
      TARGET_MISSING_ERR = 'Object does not exist: '.freeze

      #
      # Run the verb.
      #
      def run
        levels = determine_levels
        target = self.determine_target
        obj = target.resolve
        if obj
          show_target( obj, levels )
        else
          @engine.err "#{TARGET_MISSING_ERR} #{target}"
        end
      end

      #
      # Determine the target object for the show command.
      #
      def determine_target
        return @engine.heap.context if @tokens.token_count == 1

        return GlooLang::Core::Pn.new( @engine, @tokens.second )
      end

      #
      # Get the Verb's keyword.
      #
      def self.keyword
        return KEYWORD
      end

      #
      # Get the Verb's keyword shortcut.
      #
      def self.keyword_shortcut
        return KEYWORD_SHORT
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Show the target object.
      #
      def show_target( obj, levels, indent = '' )
        show_obj( obj, indent )
        return if levels.zero?

        obj.children.each do |o|
          show_target( o, levels - 1, "#{indent}  " )
        end
      end

      #
      # Show object in standard format.
      #
      def show_obj( obj, indent = '  ' )
        if obj.multiline_value? && obj.value_is_array?
          @engine.log.show "#{indent}#{obj.name} [#{obj.type_display}] :"
          obj.value.each do |line|
            @engine.log.show "#{indent}  #{line}"
          end
        else
          @engine.log.show "#{indent}#{obj.name} [#{obj.type_display}] : #{obj.value}"
        end
      end

      #
      # Determine how many levels to show.
      #
      def determine_levels
        # Check settings for the default value.
        levels = @engine.settings.list_indent
        return levels if levels

        # Last chance: use the default
        return 1
      end

    end
  end
end
