# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# If something is false, do something.
#

module Gloo
  module Verbs
    class Unless < GlooLang::Core::Verb

      KEYWORD = 'unless'.freeze
      KEYWORD_SHORT = 'if!'.freeze
      DO = 'do'.freeze
      MISSING_EXPR_ERR = 'Missing Expression!'.freeze

      #
      # Run the verb.
      #
      def run
        value = value_tokens
        return if value.nil?

        return unless evals_false( value )

        run_do
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
      # Get the list of tokens that represent the parameters
      # of the unless command.
      #
      def value_tokens
        value = @tokens.before_token( DO )
        if value && value.count > 1
          # The first token is the verb, so we drop it.
          value = value[ 1..-1 ]
        else
          @engine.err MISSING_EXPR_ERR
        end

        return value
      end

      #
      # Does the given value evalute to true?
      #
      def evals_false( value )
        eval_result = false
        if value.count.positive?
          expr = GlooLang::Expr::Expression.new( @engine, value )
          result = expr.evaluate
          eval_result = true if result == false
          eval_result = true if result.is_a?( Numeric ) && result.zero?
        end

        return eval_result
      end

      #
      # Run the 'do' command.
      #
      def run_do
        cmd = @tokens.expr_after( DO )
        i = @engine.parser.parse_immediate cmd
        return unless i

        i.run
      end

    end
  end
end
