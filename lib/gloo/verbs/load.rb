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

      #
      # Run the verb.
      #
      def run
        fn = @tokens.second

        if fn
          @engine.log.debug "Getting ready to load file: #{fn}"
          @engine.persist_man.load fn
        else
          # @engine.err MISSING_EXPR_ERR
          @engine.ext_manager.load_ext 'beep'
          # @engine.ext_manager.load_ext 'test'
          # @engine.ext_manager.load_ext 'alpha'
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

    end
  end
end
