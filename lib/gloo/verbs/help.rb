# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Show the help information.
#

module Gloo
  module Verbs
    class Help < Gloo::Core::Verb

      KEYWORD = 'help'.freeze
      KEYWORD_SHORT = '?'.freeze

      BANNER = "Entering the gloo help shell. Type 'quit' to exit.\n" \
        "Try: verbs, objects, settings, theme, extensions, libraries, docs, " \
        "verb {name}, object {name}, doc {name}, library {name}, extension {name}\n".freeze

      #
      # Run the verb.
      # Takes no arguments - always enters the interactive help shell.
      #
      def run
        @engine.log.show BANNER
        build_shell.start
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
      #    Verb Documentation
      # ---------------------------------------------------------------------

      #
      # Get the verb's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Enter the interactive help shell. From there, ' \
            'look up verbs, object types, settings, the current color ' \
            'theme, extensions, libraries, and narrative doc pages, or ' \
            'get detailed help for a specific verb, object, doc page, ' \
            'loaded library, or loaded extension.',
          :syntax => [ 'help' ],
          :result => "Enters the help shell, prompt \"help> \". Commands: " \
            'verbs, objects, settings, theme, extensions, libraries, docs ' \
            '(lists — theme also shows a color preview of both palettes), ' \
            'verb {name}, object {name}, doc {name}, library {name}, ' \
            'extension {name} (detail for one, tab-completable — library ' \
            '{name} / extension {name} show the README for a loaded core ' \
            "library / user extension). Type 'quit' to leave the shell.",
          :examples => <<~EXAMPLES.strip
            > help
            help> verbs
            help> verb put
            help> object container
            help> theme
            help> docs
            help> doc getting_started
            help> library db
            help> extension alert
            help> quit
          EXAMPLES
        }
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Build the help shell for this run.
      #
      def build_shell
        return Gloo::Docs::HelpShell.new( @engine )
      end

    end
  end
end
