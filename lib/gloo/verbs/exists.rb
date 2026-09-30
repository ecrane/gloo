# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Check to see if a verb or object type has been defined (or loaded),
# or if an object instance exists.
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
      KINDS = [ ANY_TYPE, OBJ_TYPE, VERB_TYPE, INSTANCE ].freeze
      WRONG_NUM_ARGS_ERR = 'Wrong number of arguments! 1 or 2 expected.'.freeze
      UNKNOWN_KIND_ERR = "Unknown kind '%s'! Use any, object, verb or instance.".freeze

      #
      # Run the verb.
      #
      def run
        if @tokens.token_count == 3
          type = @tokens.second.strip.downcase
          keyword = @tokens.last
          unless KINDS.include?( type )
            @engine.syntax_err format( UNKNOWN_KIND_ERR, @tokens.second )
            return @engine.heap.it.set_to( false )
          end
        elsif @tokens.token_count == 2
          type = ANY_TYPE
          keyword = @tokens.second
        else
          @engine.syntax_err WRONG_NUM_ARGS_ERR
          return @engine.heap.it.set_to( false )
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
          return @engine.dictionary.verb?(keyword) ||
            @engine.dictionary.obj?(keyword) ||
            instance_exists?(keyword)
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
          :description => 'Check to see if a verb or object type has ' \
            'been defined (or loaded), or if an object instance exists ' \
            'in the heap. With no kind, any of the three counts.',
          :syntax => [ 'exists? |any,object,verb,instance| {keyword}' ],
          :parameters => [
            "Kind of Keyword — Optional; any is the default. " \
              "any checks for a verb, an object type, or an object instance; " \
              "object checks for an object type matching the keyword or keyword " \
              "shortcut; verb checks for a verb matching the keyword or " \
              "keyword shortcut; instance checks to see if an object " \
              "instance exists at the pathname represented by keyword. " \
              "`exists? any markdown` is identical to `exists? markdown`.",
            '{keyword} — A verb or object type keyword or keyword shortcut, ' \
              'or the pathname to an object instance. Must be specified.'
          ],
          :result => 'If the verb, object type or instance exists, then ' \
            'true, otherwise false. The result will be in it.',
          :errors => [
            "#{WRONG_NUM_ARGS_ERR} The kind of keyword is optional.",
            "#{format( UNKNOWN_KIND_ERR, '{kind}' )} The kind is not one of the four."
          ],
          :notes => 'To check that a core library or extension has been ' \
            'loaded, use object: exists? object markdown. With no kind, ' \
            'an object instance with the same name would also count.',
          :examples => <<~EXAMPLES.strip
            #
            # Example of exists? keyword.
            #
            exists [container] :

            \ton_load [script] :
            \t\texists? object markdown
            \t\tshow it # false

            \t\tload lib md
            \t\texists? object markdown
            \t\tshow it # true

            \t\texists? instance exists.on_load
            \t\tshow it # true
          EXAMPLES
        }
      end

    end
  end
end
