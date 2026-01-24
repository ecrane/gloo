# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Save an object to a file or other persistance mechcanism.
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
    end
  end
end
