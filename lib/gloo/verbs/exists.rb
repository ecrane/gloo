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
      INSTANCE = 'instance'.freeze
      WRONG_NUM_ARGS_ERR = 'Wrong number of arguments! 1 or 2 expected.'.freeze

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
        elsif type == INSTANCE
          return instance_exists?(keyword)
        end

        return false
      end

      # 
      # Check to see if an instance of an object exists.
      # 
      def instance_exists?( pn )
        pn = Gloo::Core::Pn.new( @engine, pn )
        o = pn.resolve
        return false if o.nil?
        return true
      end

    end
  end
end
