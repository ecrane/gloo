# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Load an object from a file or other persistence mechanism.
#

module Gloo
  module Verbs
    class Load < Gloo::Core::Verb

      KEYWORD = 'load'.freeze
      KEYWORD_SHORT = 'ld'.freeze
      MISSING_EXPR_ERR = 'Missing Expression!'.freeze
      UNKNOWN_OPT_ERR = 'Unknown load option!'.freeze
      WRONG_NUM_ARGS_ERR = 'Wrong number of arguments! 2 or 3 expected.'.freeze
      FEATURE_NOT_IMPLEMENTED_ERR = 'Feature not implemented yet!'.freeze

      FILE_OPT = 'file'.freeze
      EXT_OPT = 'ext'.freeze
      LIB_OPT = 'lib'.freeze

      #
      # Run the verb.
      #
      def run
        return unless take_evaluated_arg

        if @tokens.token_count == 2
          opt = FILE_OPT
          fn = @tokens.second
        elsif @tokens.token_count == 3
          opt = @tokens.second.strip.downcase
          fn = @tokens.last
        else
          @engine.syntax_err WRONG_NUM_ARGS_ERR
          return
        end

        if fn.blank?
          @engine.syntax_err MISSING_EXPR_ERR
        elsif opt == FILE_OPT
          load_gloo_file fn
        elsif opt == EXT_OPT
          load_extension fn
        elsif opt == LIB_OPT
          load_library fn
        else 
          @engine.syntax_err UNKNOWN_OPT_ERR
        end
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

      #
      # Load a gloo file. A relative name is looked for in the
      # persist manager's search folders (next to this file, the
      # app or projects folder, the gloo home).
      #
      def load_gloo_file( fn )
        @engine.log.debug "Getting ready to load gloo file: #{fn}"
        pm = @engine.persist_man
        pm.load( fn, pm.search_folders )
      end

      # 
      # Load an extension
      # 
      def load_extension( name )
        @engine.log.debug "Getting ready to load extension: #{name}"
        @engine.ext_manager.load_ext name
      end

      #
      # Load a library
      #
      def load_library( name )
        @engine.log.debug "Getting ready to load library: #{name}"
        @engine.lib_manager.load_lib name
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
          :description => 'Load an object file. Give a full path, one ' \
            'starting with ~, or a relative name; the .gloo extension is ' \
            'optional. A relative name is looked for in a few places, in ' \
            'order. In App mode (--app): the app folder, then next to the ' \
            'file the loading script came from, then the gloo home. ' \
            'Otherwise: next to the loading file, then the projects ' \
            'folder (the project_path setting), then the gloo home. A ' \
            'command typed at the prompt has no file, so the working ' \
            'folder stands in for it. Using * instead of a file name ' \
            'loads all gloo files in the folder. The load verb is also ' \
            'used to import an extension or library at runtime.',
          :syntax => [
            'load {file_name}',
            'load ext {my_ext}',
            'load lib {lib_name}',
            'load [ext|lib] ( {expression} )'
          ],
          :parameters => [
            '{file_name} — Name of the object file that is to be loaded: ' \
              'a relative name (see the description for where it is ' \
              'looked for), a full path, or starting with ~. ' \
              'The .gloo extension is optional. ' \
              'End it with * to load every .gloo file in a folder, found ' \
              'the same way; the first place with matching files is ' \
              'used. Anything before the * is the start of the file names.',
            'reference type — By default, the type is file. File can be ' \
              'specified, but does not need to be. Use ext to load a ' \
              'User Extension. Use lib to load a Core Library.',
            '( {expression} ) — Instead of a literal name, an expression ' \
              'in parentheses: it is worked out and its value is used as ' \
              'the file, extension or library name. Wildcards and the ' \
              '.gloo extension work as they do for a literal name.'
          ],
          :result => 'Objects are loaded into the heap. on_load scripts ' \
            'are run within the loaded objects.',
          :errors => [
            "#{MISSING_EXPR_ERR} — No expression is provided as parameter to the verb.",
            "#{UNKNOWN_OPT_ERR} — The reference type given isn't file, ext, or lib.",
            "#{WRONG_NUM_ARGS_ERR} — load expects 2 or 3 arguments (the verb, an optional reference type, and the file/ext/lib name).",
            'File not found: {name} — The file name given could not be ' \
              'resolved to a gloo file in any of the places it is ' \
              'looked for.'
          ],
          :notes => 'Several files can contribute to one container: ' \
            'declare it in each file and add different children, and ' \
            'they merge in the heap. If two loaded files declare the ' \
            'same object with different values, the first one loaded ' \
            "wins and a warning is logged.\n\n" \
            'A file with no objects in it (empty, comments only, or ' \
            "only 'load lib' lines) loads nothing and logs a warning " \
            "naming the file; it isn't an error.\n\n" \
            'A contiguous run of whole-line comments declared ' \
            'immediately above an object (same indent, no blank line ' \
            "in between) becomes that object's doc, captured as the " \
            'file loads. Read it back with tell {obj} to doc or ' \
            'check {obj} for doc, or see it inline in the object tree ' \
            'with list when the list_docs setting is on. When a name ' \
            'is declared in more than one loaded file, the first ' \
            'non-empty doc wins, same as the first value.',
          :examples => <<~EXAMPLES.strip
            # Next to this file (or the app folder, in App mode)
            > load parts/helpers
            > load my/app/*
            > load ~/.my_app/settings.gloo
            > load ~/.my_app/plugins/*

            # Load a file whose name is worked out
            > load ( $.gloo_tmp '/scratch.gloo' )
            > load ( my.file_obj )

            # Load a User Extension
            > load ext my_ext

            # Load a Core Library
            > load lib db
          EXAMPLES
        }
      end
    end
  end
end
