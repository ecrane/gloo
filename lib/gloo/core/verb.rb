# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An abstract base verb.
# Derives from the Baseo object.
# It is a special type of object in that it can be run
# and can perform an action.
#

module Gloo
  module Core
    class Verb < Baseo

      attr_reader :tokens, :params

      BLANK_PATH_ERR = "Object path '( %s )' is blank.".freeze
      COMPUTED_PATH_DOC = '( {expression} ) — Instead of a literal ' \
        'path, an expression in parentheses: it is worked out and its ' \
        'value is used as the path, as if it had been typed there. The ' \
        "fixed part is quoted text: ( 'list.' n ). See doc " \
        'language_syntax, Computed Arguments.'.freeze

      #
      # Set up the verb.
      #
      def initialize( engine, tokens, params = [] )
        @engine = engine
        @tokens = tokens
        @params = params
      end

      #
      # Register verbs when they are loaded.
      #
      def self.inherited( subclass )
        Dictionary.instance.register_verb( subclass )
      end

      #
      # Report any syntax problem in the command's tokens or params
      # (see Tokens#syntax_problem) as a syntax error. The verb still
      # runs afterward, with the tokens' best guess.
      #
      def check_syntax
        [ @tokens, @params ].each do |t|
          problem = t.syntax_problem if t.respond_to?( :syntax_problem )
          @engine.syntax_err problem if problem
        end
      end

      #
      # For a verb that takes no object: whatever was written after it,
      # as one string (empty if nothing was).
      #
      def extra_words
        words = @tokens.respond_to?( :params ) ? @tokens.params.to_a : []
        words += @params.tokens.to_a if @params.respond_to?( :tokens )
        return words.join( ' ' )
      end

      #
      # The verb as written in the command (keyword or shortcut).
      #
      def written_verb
        written = @tokens.verb if @tokens.respond_to?( :verb )
        return written || self.class.keyword
      end

      #
      # For a harmless verb that takes no object: warn if anything was
      # written after it. The verb still runs.
      #
      def warn_extra_words
        extra = extra_words
        return if extra.empty?

        @engine.warn "#{written_verb} takes no object; ignoring '#{extra}'."
      end

      #
      # For a destructive verb that takes no object: if anything was
      # written after it, report an error and return true; the verb
      # should not run. The detail says what didn't happen and what to
      # do instead.
      #
      def extra_words_err?( detail )
        return false if extra_words.empty?

        @engine.err "#{written_verb} takes no object, so #{detail}."
        return true
      end

      #
      # For a verb whose arguments are literal text (a file name, a
      # path, a name): a trailing ( expr ) is worked out and its value
      # added as the last argument, so the text can be computed, as in
      # load ( $.gloo_tmp '/x.gloo' ). The parser has already split the
      # parenthetical off into params. Returns false if the expression
      # couldn't be worked out (already reported), true otherwise.
      #
      def take_evaluated_arg
        return take_leading_group_arg unless @params

        value, ok = evaluate_expr( @params.tokens )
        return false unless ok

        @tokens = @tokens.with_token( value.to_s )
        @params = nil
        return true
      end

      #
      # The whole argument is a group right after the verb, as in
      # load ( x ): the parser leaves that in the tokens (it groups,
      # see Parser#split_params), so it's worked out here and its value
      # put in its place. Returns false if the expression couldn't be
      # worked out (already reported), true otherwise.
      #
      def take_leading_group_arg
        return true unless @tokens.respond_to?( :token_count )

        last = path_group_end( 1 )
        return true unless last && last == @tokens.token_count - 1

        value, ok = evaluate_expr( Gloo::Core::Tokens.new( path_group_text( 1, last ) ).tokens )
        return false unless ok

        @tokens = @tokens.with_tokens_replaced( 1, last, value.to_s )
        return true
      end

      #
      # For a verb whose argument at the given position is an object
      # path: a ( expr ) group there is worked out, and its value put
      # back as one token, so the path can be computed, as in
      # put 1 into ( 'counts.' key ). The verb then reads its arguments
      # as usual. The position is a token index (1 for the word after
      # the verb), or a keyword, meaning the token after it ('into').
      #
      # The group is either mid-line, in the tokens (tell ( t ) to run),
      # or, when the path is the last argument, already split off by
      # the parser into params (put 1 into ( x )). A trailing group
      # after some other argument (tell t to run ( 1 )) is left alone.
      # Returns false if the expression couldn't be worked out (already
      # reported), true otherwise.
      #
      def take_path_arg( position )
        return true unless @tokens.respond_to?( :token_count )

        i = path_arg_index( position )
        return true unless i

        return take_trailing_path_arg if i == @tokens.token_count

        last = path_group_end( i )
        return true unless last

        text = path_group_text( i, last )
        value, ok = evaluate_expr( Gloo::Core::Tokens.new( text ).tokens )
        return false unless ok && path_value_given?( value, text )

        @tokens = @tokens.with_tokens_replaced( i, last, value.to_s )
        return true
      end

      #
      # The token index of the path argument at the given position:
      # an index as given, or the one after a keyword. Nil if the
      # keyword isn't there.
      #
      def path_arg_index( position )
        return position if position.is_a?( Integer )

        i = @tokens.index_of( position )
        return i ? i + 1 : nil
      end

      #
      # The path is the last argument and has no token: if the parser
      # split a trailing group off into params, that's the path. Work
      # it out and add it as the last token.
      #
      def take_trailing_path_arg
        return true unless @params.respond_to?( :tokens )

        value, ok = evaluate_expr( @params.tokens )
        return false unless ok && path_value_given?( value, @params.tokens.join( ' ' ) )

        @tokens = @tokens.with_token( value.to_s )
        @params = nil
        return true
      end

      #
      # A worked-out path must have some text; blank is reported (the
      # group's text, as written, names it) and the verb doesn't run.
      #
      def path_value_given?( value, text )
        return true unless value.to_s.strip.empty?

        @engine.err format( BLANK_PATH_ERR, text.strip )
        return false
      end

      #
      # If the token at index i opens a group, the index of the token
      # that closes it; nil if it doesn't open one or never closes. A
      # group can be written ( p ), (p) or ('a.' b), so parentheses are
      # counted in each token; a quoted token is text and isn't counted.
      #
      def path_group_end( i )
        return nil unless @tokens.at( i )&.start_with?( '(' )

        depth = 0
        ( i...@tokens.token_count ).each do |j|
          token = @tokens.at( j )
          next if Gloo::Core::Tokens::QUOTE_CHARS.include?( token[ 0 ] )

          depth += token.count( '(' ) - token.count( ')' )
          return j if depth <= 0
        end
        return nil
      end

      #
      # The text inside the group from token first to token last, with
      # its outer parentheses taken off.
      #
      def path_group_text( first, last )
        text = ( first..last ).map { |j| @tokens.at( j ) }.join( ' ' )
        return text.strip[ 1..-2 ]
      end

      #
      # Work out an expression from the given tokens. Returns the value
      # and whether it worked: false if the expression reported a
      # problem (already reported), in which case the value is whatever
      # it had worked out so far.
      #
      def evaluate_expr( tokens )
        errors_before = @engine.heap.error.error_count
        value = Gloo::Expr::Expression.new( @engine, tokens ).evaluate
        return value, @engine.heap.error.error_count == errors_before
      end

      #
      # Run the verb.
      #
      # We'll mark the application as not running and let the
      # engine stop gracefully next time through the loop.
      #
      def run
        raise 'this method should be overriden'
      end

      #
      # Get the Verb's keyword.
      #
      # The keyword will be in lower case only.
      # It is used by the parser.
      #
      def self.keyword
        raise 'this method should be overriden'
      end

      #
      # Get the Verb's keyword shortcut.
      #
      def self.keyword_shortcut
        raise 'this method should be overriden'
      end

      #
      # The object type, suitable for display.
      #
      def type_display
        return self.class.keyword
      end

      #
      # Generic function to get display value.
      # Can be used for debugging, etc.
      #
      def display_value
        return self.class.keyword
      end

      # ---------------------------------------------------------------------
      #    Help
      # ---------------------------------------------------------------------

      #
      # Get help for this verb.
      #
      def self.help
        return 'No help found.'
      end

    end
  end
end
