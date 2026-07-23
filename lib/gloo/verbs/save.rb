# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Save an object to a file or other persistance mechcanism.
#

module Gloo
  module Verbs
    class Save < Gloo::Core::Verb

      KEYWORD = 'save'.freeze
      KEYWORD_SHORT = 'sv'.freeze

      #
      # Run the verb.
      #
      def run
        # TODO:  Not currently using folders or keeping
        # track of where the object was loaded from.
        @engine.persist_man.save @tokens.second
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
          :description => 'Save a previously loaded object to a .gloo ' \
            'file. The path will be for the root level object that was ' \
            'loaded earlier.',
          :syntax => [ 'save {path.to.object}' ],
          :parameters => [
            '{path.to.object} — Name of the object file that is to be saved.'
          ],
          :result => 'The file is updated with the latest object state.',
          :notes => 'The save verb is not currently fully functional.',
          :examples => <<~EXAMPLES.strip
            > save my_obj
          EXAMPLES
        }
      end

    end
  end
end
