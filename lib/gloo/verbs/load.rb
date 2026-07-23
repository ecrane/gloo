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
        if @tokens.token_count == 2
          opt = FILE_OPT
          fn = @tokens.second
        elsif @tokens.token_count == 3
          opt = @tokens.second.strip.downcase
          fn = @tokens.last
        else
          @engine.err WRONG_NUM_ARGS_ERR
          return
        end

        if fn.blank?
          @engine.err MISSING_EXPR_ERR
        elsif opt == FILE_OPT
          load_gloo_file fn
        elsif opt == EXT_OPT
          load_extension fn
        elsif opt == LIB_OPT
          load_library fn
        else 
          @engine.err UNKNOWN_OPT_ERR
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
      # Load a gloo file
      # 
      def load_gloo_file( fn )
        @engine.log.debug "Getting ready to load gloo file: #{fn}"
        @engine.persist_man.load fn
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
          :description => 'Load an object file. There are two ways to ' \
            'specify the file. Give either the full path and file name ' \
            'or use a relative path from the gloo project folder. For ' \
            'the latter, the extension is not needed. For the former, ' \
            'the file extension is necessary. Using * instead of a file ' \
            'name will load all gloo files in the folder. When using the ' \
            '--app option, the file is loaded from the application ' \
            'folder, but if not found there, the loader will also look ' \
            'in the gloo root folder. The load verb is also used to ' \
            'import an extension or library at runtime.',
          :syntax => [
            'load {file_name}',
            'load ext {my_ext}',
            'load lib {lib_name}'
          ],
          :parameters => [
            '{file_name} — Name of the object file that is to be loaded.',
            'reference type — By default, the type is file. File can be ' \
              'specified, but does not need to be. Use ext to load a ' \
              'User Extension. Use lib to load a Core Library.'
          ],
          :result => 'Objects are loaded into the heap. on_load scripts ' \
            'are run within the loaded objects.',
          :errors => [
            "#{MISSING_EXPR_ERR} — No expression is provided as parameter to the verb.",
            'File not Found — If the file specified cannot be found or cannot be loaded, an error condition will result.'
          ],
          :examples => <<~EXAMPLES.strip
            > load my/project/file
            > load my/app/*
            > load ~/.my_app/settings.gloo

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
