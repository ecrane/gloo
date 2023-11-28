# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# Unload all files.
#

module Gloo
  module Verbs
    class Unload < Gloo::Core::Verb

      KEYWORD = 'unload'.freeze
      KEYWORD_SHORT = 'u!'.freeze

      #
      # Run the verb.
      #
      def run
        return unless @engine.persist_man.maps
        
        @engine.persist_man.unload_all
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
