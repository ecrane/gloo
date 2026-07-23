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
      # This will unload all loaded objects and reset the engine state.
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
          :description => 'Un-load all open files. Use the files ' \
            'command to see the list of files that will be un-loaded. ' \
            'The heap will be empty after this is run, so be sure to ' \
            'save state prior to executing.',
          :syntax => [ 'unload' ],
          :result => 'All objects will be unloaded from the heap.',
          :examples => <<~EXAMPLES.strip
            > unload
          EXAMPLES
        }
      end

    end
  end
end
