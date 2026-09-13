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
            "default path built from the object's own name. With a " \
            'path, this extracts: the object (and its descendants) ' \
            "move out of whichever file currently owns them -- they're " \
            'no longer declared there too -- into the new file, under ' \
            'their full dotted path (so any parent containers are ' \
            'recreated there via nested-container shorthand).',
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
          :result => 'The file(s) are updated with the latest object ' \
            'state. This is a rewrite, not a regeneration: comments, ' \
            'blank lines, and the original formatting are preserved, ' \
            'and only values that actually changed are re-written. ' \
            'With a path, the object also stops being declared in its ' \
            'old file (if it had one) -- both files are rewritten ' \
            'together.',
          :errors => [
            "#{MISSING_PATH_ERR} — 'to' was given with nothing after it.",
            'Could not resolve object to save — the object was not found.',
            'Will not overwrite a file not already saved there — the ' \
              'target path exists but is not mapped to this object.',
            "Can't extract: this object's subtree has declarations in " \
              'more than one file — save each contributing file on its ' \
              'own first, then extract.',
            "Can't extract: this object has no declaration of its own " \
              'to move — it may be an auto-created intermediate ' \
              'container from nested-container shorthand; extract a ' \
              'child that does, or a shallower ancestor that does.'
          ],
          :notes => 'An object can also be told to save itself: ' \
            '`tell my_obj to save`. When several files contribute to ' \
            'one container (the namespace pattern), each file save only ' \
            "rewrites that file's own declarations. Extraction (save " \
            '... to {path}) only moves a subtree owned by exactly one ' \
            'file -- one already spread across several files (that ' \
            'same namespace pattern, applied inside the subtree being ' \
            'extracted) is refused rather than guessed at.',
          :examples => <<~EXAMPLES.strip
            > save
            > save my_obj
            > save my_obj to sub/my_obj
            > save app.core.settings to config/settings
          EXAMPLES
        }
      end

    end
  end
end
