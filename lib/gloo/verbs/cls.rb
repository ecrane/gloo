# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Clear the screen.
#

module Gloo
  module Verbs
    class Cls < Gloo::Core::Verb

      KEYWORD = 'clear'.freeze
      KEYWORD_SHORT = 'cls'.freeze

      #
      # Run the verb.
      #
      def run
        @engine.platform&.clear_screen
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
          :description => 'Clear the console screen.',
          :syntax => [ 'clear' ],
          :result => 'The screen is cleared and cursor set to the top.',
          :examples => '> clear'
        }
      end

    end
  end
end
