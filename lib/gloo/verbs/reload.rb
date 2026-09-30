# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# Reload all files.
#

module Gloo
  module Verbs
    class Reload < Gloo::Core::Verb

      KEYWORD = 'reload'.freeze
      KEYWORD_SHORT = 'r!'.freeze

      #
      # Run the verb.
      # First all objects will be notified of the event.
      # Then the engine will restart with the original parameters.
      #
      def run
        return if extra_words_err?( 'nothing was reloaded; to reload one object, use tell x to reload' )

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
          :description => 'Re-load to original state. This will ' \
            'essentially re-run gloo with the parameters given during ' \
            'start-up. Use the files command to see the list of files ' \
            'that will be re-loaded. Any changes made externally in the ' \
            'stored files will take effect.',
          :syntax => [ 'reload' ],
          :result => 'Each open file will be first unloaded and then ' \
            'loaded again. Note that re-load does not trigger the ' \
            'on_load script to run. There is an on_reload message sent ' \
            'to all open files.',
          :errors => [
            'reload takes no object, so nothing was reloaded — anything ' \
              'written after reload is an error, and nothing is reloaded. ' \
              'To reload one object, use tell x to reload.'
          ],
          :notes => 'If a file has changes that have not been saved, ' \
            'reloading discards them (a warning is logged, but the ' \
            'reload still proceeds). reload takes no object; to reload ' \
            'just one object\'s file, send it the reload message.',
          :examples => <<~EXAMPLES.strip
            > reload
          EXAMPLES
        }
      end

    end
  end
end
