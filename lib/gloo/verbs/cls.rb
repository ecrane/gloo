# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Clear the screen.
#

module Gloo
  module Verbs
    class Cls < Gloo::Core::Verb

      KEYWORD = 'cls'.freeze
      KEYWORD_SHORT = 'cls'.freeze

      #
      # Run the verb.
      #
      def run
        $engine&.clear_screen
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

    end
  end
end
