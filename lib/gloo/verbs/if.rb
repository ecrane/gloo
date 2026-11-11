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
      DO = 'do'.freeze
      ELSE = 'else'.freeze
      # 'then' and 'do' are interchangeable -- whichever appears first
      # in the tokens is the actual separator (see Tokens#index_of).
      SEPARATORS = [ THEN, DO ].freeze
      MISSING_EXPR_ERR = 'Missing Expression!'.freeze

      #
      # Run the verb.
      #
      def run
        value = value_tokens
        return if value.nil?

        @then = @tokens.expr_after( SEPARATORS, ELSE )
        @else = @tokens.expr_after( ELSE )
        give_params_to_last_part

        truth = evals_true( value )
        # A condition that reported an error abandons the line.
        return if truth.nil?

        if truth
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
      # A trailing ( ... ) the parser split off the line belongs to the
      # command at the end of it (eg. show's colour in
      # if x then show 'a' (red)): give it back to the else part if
      # there is one, otherwise to the then part.
      #
      def give_params_to_last_part
        return unless @params.respond_to?( :cmd )

        group = " ( #{@params.cmd} )"
        if !@else.blank?
          @else += group
        elsif !@then.blank?
          @then += group
        end
      end

      #
      # Get the list of tokens that represent the parameters
      # of the if command.
      #
      def value_tokens
        value = @tokens.before_token( SEPARATORS )
        if value && value.count > 1
          # The first token is the verb, so we drop it.
          value = value[ 1..-1 ]
        else
          @engine.syntax_err MISSING_EXPR_ERR
        end

        return value
      end

      #
      # Does the given value evalute to true? The [bool] rule decides
      # (see Boolean.to_bool). Nil if working it out reported an error.
      #
      def evals_true( value )
        result, ok = evaluate_expr( value )
        return nil unless ok

        return Gloo::Objs::Boolean.to_bool( @engine, result )
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
          :description => 'If an expression is true then do something. ' \
            "'then' and 'do' are interchangeable separators -- pick " \
            'whichever reads better.',
          :syntax => [
            'if {true} then {action}',
            'if {true} do {action}',
            'if {true} then {action} else {else action}'
          ],
          :parameters => [
            '{true} — Does the expression evaluate to true?',
            '{action} — Execute command if the expression is true.',
            '{else action} — The else command is optional. Execute command if the expression is false.'
          ],
          :result => 'Unchanged if the expression is not true. If true, ' \
            'then the result will be based on the command specified ' \
            "after the 'then'/'do' keyword.",
          :errors => [
            "#{MISSING_EXPR_ERR} — No expression is provided as parameter to the verb.",
            'Other errors depend on the command that is run.'
          ],
          :notes => 'What counts as true follows the [bool] rule: true, a ' \
            'number other than 0, and the text true or t are true; anything ' \
            'else is false (blank quietly, other text with a warning). See ' \
            'doc language_syntax, What Counts as True. A condition that ' \
            'reports an error abandons the line: neither command runs.',
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

                # 'do' works the same as 'then'
                if if.x do show "still true: " + if.true_msg
          EXAMPLES
        }
      end
    end
  end
end
