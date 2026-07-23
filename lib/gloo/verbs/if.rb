# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# If something is true, do something.
#

module Gloo
  module Verbs
    class If < Gloo::Core::Verb

      KEYWORD = 'if'.freeze
      KEYWORD_SHORT = 'if'.freeze
      THEN = 'then'.freeze
      ELSE = 'else'.freeze
      MISSING_EXPR_ERR = 'Missing Expression!'.freeze

      #
      # Run the verb.
      #
      def run
        value = value_tokens
        return if value.nil?

        @then = @tokens.expr_after( THEN, ELSE )
        @else = @tokens.expr_after( ELSE )

        if evals_true( value )
          run_then
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
      # of the if command.
      #
      def value_tokens
        value = @tokens.before_token( THEN )
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
      def evals_true( value )
        eval_result = false
        if value.count.positive?
          expr = Gloo::Expr::Expression.new( @engine, value )
          result = expr.evaluate
          eval_result = true if result == true
          eval_result = true if result.is_a?( Numeric ) && result != 0
        end

        return eval_result
      end

      #
      # Run the 'then' command.
      #
      def run_then
        i = @engine.parser.parse_immediate @then
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
          :description => 'If an expression is true then do something.',
          :syntax => [
            'if {true} then {do}',
            'if {true} then {do} else {do else}'
          ],
          :parameters => [
            '{true} — Does the expression evaluate to true?',
            '{do} — Execute command if the expression is true.',
            '{do else} — The else command is optional. Execute command if the expression is false.'
          ],
          :result => 'Unchanged if the expression is not true. If true, ' \
            'then the result will be based on the command specified ' \
            'after the then keyword.',
          :errors => [
            "#{MISSING_EXPR_ERR} — No expression is provided as parameter to the verb.",
            'Other errors depend on the command that is run.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # If statement example
            #

            if [container] :

              x [bool] : false
              true_msg [string] : It is true!

              on_load [script] :
                if if.x then show "first time: " + if.true_msg
                if ^.x then show 'T' else show 'F'

                put true into if.x
                if if.x \\
                  then show "second time: " + if.true_msg
                if ^.x \\
                  then show 'T' \\
                  else show 'F'
          EXAMPLES
        }
      end
    end
  end
end
