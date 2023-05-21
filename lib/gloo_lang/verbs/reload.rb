# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# Reload all files.
#

module GlooLang
  module Verbs
    class Reload < GlooLang::Core::Verb

      KEYWORD = 'reload'.freeze
      KEYWORD_SHORT = 'r!'.freeze

      #
      # Run the verb.
      #
      def run
        @engine.persist_man.reload_all
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

    end
  end
end
