# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Check to see if a verb or object type has been defined (or loaded).
#

module Gloo
  module Verbs
    class Exists < Gloo::Core::Verb

      KEYWORD = 'exists?'.freeze
      KEYWORD_SHORT = 'exist'.freeze
      VERB_TYPE = 'verb'.freeze
      OBJ_TYPE = 'object'.freeze
      ANY_TYPE = 'any'.freeze
      MISSING_EXPR_ERR = 'Missing Expression!'.freeze
      WRONG_NUM_ARGS_ERR = 'Wrong number of arguments! 2 or 3 expected.'.freeze

      #
      # Run the verb.
      #
      def run
        if @tokens.token_count == 3
          type = @tokens.second.strip.downcase
          keyword = @tokens.last
        elsif @tokens.token_count == 2
          type = ANY_TYPE
          keyword = @tokens.second
        else
          @engine.err WRONG_NUM_ARGS_ERR
          return
        end
        
        @engine.heap.it.set_to lookup_keyword(keyword, type)
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
      # Lookup a keyword in the dictionary.
      # 
      def lookup_keyword( keyword, type )
        if type == VERB_TYPE
          return @engine.dictionary.verb?(keyword)
        elsif type == OBJ_TYPE
          return @engine.dictionary.obj?(keyword)
        elsif type == ANY_TYPE
          return @engine.dictionary.verb?(keyword) || @engine.dictionary.obj?(keyword)
        end

        return false
      end

    end
  end
end
