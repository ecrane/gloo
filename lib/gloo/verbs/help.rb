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
        "Try: verbs, objects, settings, extensions, libraries, docs, " \
        "verb {name}, object {name}, doc {name}, library {name}\n".freeze

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
            'look up verbs, object types, settings, extensions, libraries, ' \
            'and narrative doc pages, or get detailed help for a specific ' \
            'verb, object, doc page, or loaded library.',
          :syntax => [ 'help' ],
          :result => "Enters the help shell, prompt \"help> \". Commands: " \
            'verbs, objects, settings, extensions, libraries, docs (lists), ' \
            'verb {name}, object {name}, doc {name}, library {name} ' \
            '(detail for one, tab-completable — library {name} shows the ' \
            "README for a loaded core library). Type 'quit' to leave the shell.",
          :examples => <<~EXAMPLES.strip
            > help
            help> verbs
            help> verb put
            help> object container
            help> docs
            help> doc getting_started
            help> library db
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
