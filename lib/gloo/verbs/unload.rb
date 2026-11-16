# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# Unload all files, or one library or extension.
#

module Gloo
  module Verbs
    class Unload < Gloo::Core::Verb

      KEYWORD = 'unload'.freeze
      KEYWORD_SHORT = 'u!'.freeze

      LIB_OPT = 'lib'.freeze
      EXT_OPT = 'ext'.freeze

      WRONG_ARGS_ERR = 'unload takes nothing, or lib or ext and a name, ' \
        'so nothing was unloaded; to unload one object, use tell x to unload.'.freeze
      MISSING_NAME_ERR = 'Missing the name of the library or extension to unload!'.freeze

      #
      # Run the verb.
      # With nothing after it, this unloads all loaded objects and
      # resets the engine state; with lib or ext and a name, it unloads
      # that library or extension.
      #
      def run
        return unless take_evaluated_arg

        return unload_all if @tokens.token_count == 1

        opt = @tokens.second.strip.downcase
        unless [ LIB_OPT, EXT_OPT ].include?( opt ) && @tokens.token_count <= 3
          @engine.err WRONG_ARGS_ERR
          return @engine.heap.it.set_to( false )
        end

        name = @tokens.at( 2 )
        if name.blank?
          @engine.syntax_err MISSING_NAME_ERR
          return @engine.heap.it.set_to( false )
        end

        unload_plugin( opt, name )
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
      # Unload all files, emptying the heap.
      #
      def unload_all
        return unless @engine.persist_man.maps

        @engine.persist_man.unload_all
      end

      #
      # Unload the named library (lib) or extension (ext). If it
      # couldn't be unloaded (already reported), it is false.
      #
      def unload_plugin( opt, name )
        ok = if opt == LIB_OPT
               @engine.lib_manager.unload_lib( name )
             else
               @engine.ext_manager.unload_ext( name )
             end
        @engine.heap.it.set_to false unless ok
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
          :description => 'Un-load all open files, or one library or ' \
            'extension. With nothing after it, unload empties the heap: ' \
            'use the files command to see the list of files that will be ' \
            'un-loaded, and be sure to save state first. With lib or ext ' \
            'and a name, it unloads that library or extension: its verbs ' \
            'and object types are gone until it is loaded again.',
          :syntax => [ 'unload', 'unload lib {name}', 'unload ext {name}' ],
          :parameters => [
            'lib {name} or ext {name} (optional) — the library or extension ' \
              'to unload, as given to load. The name can be worked out: ' \
              'unload lib ( name ).'
          ],
          :result => 'With nothing after it, all objects are unloaded from ' \
            'the heap. With lib or ext, that library\'s or extension\'s ' \
            'verbs and object types are removed; load lib or load ext ' \
            'brings them back.',
          :errors => [
            'Anything else after unload is an error, and nothing is ' \
              'unloaded. To unload one object, use tell x to unload.',
            'unload lib or unload ext without a name is a syntax error.',
            'A library or extension can\'t be unloaded while objects of ' \
              'its types are on the heap: it is an error naming them, and ' \
              'nothing is unloaded.',
            'A library gloo loaded itself (gloo-test, when running tests) ' \
              'can\'t be unloaded: it is an error.'
          ],
          :notes => 'Plain unload keeps loaded libraries and extensions. ' \
            'Unloading a library or extension that isn\'t loaded ' \
            'does nothing. Its Ruby code stays loaded, so any settings or ' \
            'caches of its own aren\'t reset. To unload just one object, ' \
            'send it the unload message (tell x to unload).',
          :examples => <<~EXAMPLES.strip
            > unload
            > unload lib md
            > exists? object markdown
            > load lib md
          EXAMPLES
        }
      end

    end
  end
end
