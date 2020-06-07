# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Play a standard system beep sound.
#

module Gloo
  module Verbs
    class Beep < Gloo::Core::Verb

      KEYWORD = 'beep'.freeze
      KEYWORD_SHORT = 'b'.freeze

      #
      # Run the verb.
      #
      # We'll mark the application as not running and let the
      # engine stop gracefully next time through the loop.
      #
      def run
        puts 7.chr
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
      #    Help
      # ---------------------------------------------------------------------

      #
      # Get help for this verb.
      #
      def self.help
        return <<~TEXT
          BEEP VERB
            NAME: beep
            SHORTCUT: b

          DESCRIPTION
            Play a standard system beep sound.

          SYNTAX
            beep

          PARAMETERS
            None

          RESULT
            None

          ERRORS
            None
        TEXT
      end

    end
  end
end
