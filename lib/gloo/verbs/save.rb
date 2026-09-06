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
      TO = 'to'.freeze
      MISSING_PATH_ERR = "'Save ... to' must include a path!".freeze

      #
      # Run the verb.
      #
      def run
        return @engine.persist_man.save @tokens.second unless @tokens.index_of( TO )

        run_save_to
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

      #
      # Run 'save {obj} to {path}'.
      #
      def run_save_to
        name = @tokens.before_token( TO )[ 1 ]
        path = @tokens.after_token( TO )
        unless path
          @engine.err MISSING_PATH_ERR
          return
        end

        @engine.persist_man.save_to( name, path )
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
          :description => 'Save an object to a .gloo file. With no ' \
            'path, saves every file that owns a declaration in the ' \
            "object's root (its file, or every contributing file for " \
            'a namespace shared across several files); with no object ' \
            'at all, saves every open file. An object not yet mapped ' \
            'to a file is saved fresh, either to a given path or to a ' \
            "default path built from the object's own name.",
          :syntax => [
            'save',
            'save {path.to.object}',
            'save {path.to.object} to {path}'
          ],
          :parameters => [
            '{path.to.object} — Name of the object to save.',
            '{path} — Where to save it, relative to the project root ' \
              '(.gloo appended if omitted). Registers the mapping, so ' \
              'a later bare save includes it.'
          ],
          :result => 'The file(s) are updated with the latest object state.',
          :errors => [
            "#{MISSING_PATH_ERR} — 'to' was given with nothing after it.",
            'Could not resolve object to save — the object was not found.',
            'Will not overwrite a file not already saved there — the ' \
              'target path exists but is not mapped to this object.'
          ],
          :notes => 'An object can also be told to save itself: ' \
            '`tell my_obj to save`.',
          :examples => <<~EXAMPLES.strip
            > save
            > save my_obj
            > save my_obj to sub/my_obj
          EXAMPLES
        }
      end

    end
  end
end
