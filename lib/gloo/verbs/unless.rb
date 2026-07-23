# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# If something is false, do something.
#

module Gloo
  module Verbs
    class Unless < Gloo::Core::Verb

      KEYWORD = 'unless'.freeze
      KEYWORD_SHORT = 'if!'.freeze
      DO = 'do'.freeze
      ELSE = 'else'.freeze
      MISSING_EXPR_ERR = 'Missing Expression!'.freeze

      #
      # Run the verb.
      #
      def run
        value = value_tokens
        return if value.nil?

        @do = @tokens.expr_after( DO, ELSE )
        @else = @tokens.expr_after( ELSE )

        if evals_false( value )
          run_do
        else
          run_else unless @else.blank?
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
          expr = Gloo::Expr::Expression.new( @engine, value )
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
        i = @engine.parser.parse_immediate @do
        return unless i

        i.run
      end

      #
      # Run the 'else' command.
      #
      def run_else
        i = @engine.parser.parse_immediate @else
        return unless i

        i.run
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
          :description => "Unless an expression is true, do something. " \
            "This is the opposite of the if verb.",
          :syntax => [
            'unless {true} do {command}',
            'unless {true} do {command} else {else command}'
          ],
          :parameters => [
            '{true} — Does the expression evaluate to true?',
            '{command} — Execute command if the expression is false.',
            '{else command} — The else command is optional. Execute else command if the expression is true.'
          ],
          :result => 'Unchanged if the expression is true. If not true, ' \
            'then the result will be based on the command specified ' \
            'after the do keyword.',
          :errors => [
            "#{MISSING_EXPR_ERR} — No expression is provided as parameter to the verb.",
            'Other errors depend on the command that is run.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Unless statement example
            #

            unless [container] :

              x [bool] : true
              false_msg [string] : It is NOT true!

              on_load [script] :
                unless unless.x do show "first time: " + unless.false_msg
                unless ^.x do show 'F' else show 'T'

                put false into unless.x
                unless unless.x do show "second time: " +  unless.false_msg
                unless ^.x do show 'F' else show 'T'
          EXAMPLES
        }
      end
    end
  end
end
