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
            'been defined (or loaded). This verb can be used to check ' \
            'if a core library or extension has been loaded.',
          :syntax => [ 'exists? |any,object,verb,instance| {keyword}' ],
          :parameters => [
            "Kind of Keyword — Check for the presence of a keyword of a kind. " \
              "any (default, optional) checks for either an object or a verb; " \
              "object checks for an object matching the keyword or keyword " \
              "shortcut; verb checks for a verb matching the keyword or " \
              "keyword shortcut; instance checks to see if an object " \
              "instance exists at the pathname represented by keyword. " \
              "`exists? any markdown` is identical to `exists? markdown`.",
            '{keyword} — The verb or object keyword or keyword shortcut. ' \
              'Must be specified. For the instance option, the keyword is ' \
              'the pathname to an object instance.'
          ],
          :result => 'If the object or verb has been defined, then true, ' \
            'otherwise false. The result will be in it.',
          :errors => [
            "#{WRONG_NUM_ARGS_ERR} The kind of keyword is optional."
          ],
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
