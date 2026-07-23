# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# List out an object and it's children.
#

module Gloo
  module Verbs
    class List < Gloo::Core::Verb

      KEYWORD = 'list'.freeze
      KEYWORD_SHORT = '.'.freeze
      TARGET_MISSING_ERR = 'Object does not exist: '.freeze

      #
      # Run the verb.
      #
      def run
        levels = determine_levels
        target = self.determine_target
        indent = self.determine_indent

        obj = target.resolve
        if obj
          show_target( obj, levels, indent )
        else
          @engine.err "#{TARGET_MISSING_ERR} #{target}"
        end
      end

      #
      # Determine the target object for the show command.
      #
      def determine_target
        return @engine.heap.context if @tokens.token_count == 1

        return Gloo::Core::Pn.new( @engine, @tokens.second )
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
          show_target( o, levels - 1, "#{indent}#{determine_indent}" )
        end
      end

      #
      # Show object in standard format.
      #
      def show_obj( obj, indent = '  ' )
        if obj.multiline_value? && obj.value_is_array?
          str = "#{indent}#{obj.name}".white
          str << " [#{obj.type_display}] : ".yellow
          @engine.log.show str
          obj.value.each do |line|
            @engine.log.show "#{indent}  #{line}"
          end
        else
          str = "#{indent}#{obj.name}".white
          str << " [#{obj.type_display}] : ".yellow
          str << "#{obj.value}"
          @engine.log.show str
        end
      end

      #
      # Determine how many levels to show.
      #
      def determine_levels
        # Check settings for the default value.
        levels = @engine.settings.list_levels
        return levels if levels

        # Last chance: use the default
        return 1
      end

      #
      # Determine the level of indentation in the outline.
      #
      def determine_indent
        # Check settings for the default value.
        indent = @engine.settings.list_indent
        if indent
          return ( ' ' * indent )
        end

        # Last chance: use the default
        return '  '
      end

      # ---------------------------------------------------------------------
      #    Verb Documentation
      # ---------------------------------------------------------------------

      #
      # Get the verb's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'List out objects (and children) at the ' \
            'current context. When a path is provided, it will be ' \
            'listed instead of the current context. When using context, ' \
            'the current context will be shown, but when context has ' \
            'not been set, the root will be shown.',
          :syntax => [ 'list {path.to.object}' ],
          :parameters => [
            '{path.to.object} — Optional path to object that will be listed. When no path is provided, the current context is used.'
          ],
          :result => 'Object and children are listed out in the CLI.',
          :errors => [
            "#{TARGET_MISSING_ERR}{path.to.object} — The object specified that is to be listed could not be found."
          ],
          :examples => <<~EXAMPLES.strip
            > list
            > list my.container
            > list root
          EXAMPLES
        }
      end

    end
  end
end
