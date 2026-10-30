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
        name = @tokens.second
        return if name && Gloo::Core::Pn.new( @engine, name ).it_target_err?( 'saved' )
        return @engine.persist_man.save name unless @tokens.index_of( TO )

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
        return unless take_evaluated_arg

        name = @tokens.before_token( TO )[ 1 ]
        path = @tokens.after_token( TO )
        if path.blank?
          @engine.syntax_err MISSING_PATH_ERR
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
            'save {path.to.object} to {path}',
            'save {path.to.object} to ( {expression} )'
          ],
          :parameters => [
            '{path.to.object} — Name of the object to save.',
            '{path} — Where to save it, relative to the project root ' \
              '(.gloo appended if omitted). Registers the mapping, so ' \
              'a later bare save includes it.',
            '( {expression} ) — Instead of a literal path, an expression ' \
              'in parentheses: it is worked out and its value is used as ' \
              'the path.'
          ],
          :result => 'The file(s) are updated with the latest object ' \
            'state. This is a rewrite, not a regeneration: comments, ' \
            'blank lines, and the original formatting are preserved, ' \
            'and only values that actually changed are re-written. ' \
            'A declaration you never touched comes back byte-for-byte. ' \
            'An object counts as changed only when its value is set or ' \
            'it is created, moved, or deleted (its doc comment goes with ' \
            'it); changes to its children do not change it. A changed ' \
            'declaration keeps its name, type and spacing; only its ' \
            'value is written again. A new object goes after the last ' \
            "child of its parent's first declaration, in the file's " \
            'indentation and type spellings. An object declared on more ' \
            'than one line has its value on the first: a change rewrites ' \
            'only that line, and deleting or moving it takes all its ' \
            'lines. ' \
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
          :notes => 'A value that cannot be written exactly (a block ' \
            'value with no final line break, a line that is just END, ' \
            'bytes that are not UTF-8) is written as closely as possible, ' \
            "with a warning: Could not save '{path}' exactly: {why}. A " \
            'changed script body loses the comments and blank lines ' \
            'inside it. A new top-level object has no file yet: a bare ' \
            'save leaves it out and warns (Not saved (no file yet): ' \
            '{name}.); save {name} gives it a file of its own. ' \
            'See doc verbs, Load & Save. ' \
            'An object can also be told to save itself: ' \
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
            > save my_obj to ( $.gloo_tmp '/my_obj' )
          EXAMPLES
        }
      end

    end
  end
end
