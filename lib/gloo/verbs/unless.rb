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
      THEN = 'then'.freeze
      ELSE = 'else'.freeze
      # 'do' and 'then' are interchangeable -- whichever appears first
      # in the tokens is the actual separator (see Tokens#index_of).
      SEPARATORS = [ DO, THEN ].freeze
      MISSING_EXPR_ERR = 'Missing Expression!'.freeze

      #
      # Run the verb.
      #
      def run
        value = value_tokens
        return if value.nil?

        @do = @tokens.expr_after( SEPARATORS, ELSE )
        @else = @tokens.expr_after( ELSE )

        truth = evals_false( value )
        # A condition that reported an error abandons the line.
        return if truth.nil?

        if truth
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
      # Does the given value evalute to false? The exact opposite of if:
      # the [bool] rule decides (see Boolean.to_bool). Nil if working it
      # out reported an error.
      #
      def evals_false( value )
        result, ok = evaluate_expr( value )
        return nil unless ok

        return !Gloo::Objs::Boolean.to_bool( @engine, result )
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
            "This is the opposite of the if verb. 'do' and 'then' are " \
            'interchangeable separators -- pick whichever reads better.',
          :syntax => [
            'unless {true} do {command}',
            'unless {true} then {command}',
            'unless {true} do {command} else {else command}'
          ],
          :parameters => [
            '{true} — Does the expression evaluate to true?',
            '{command} — Execute command if the expression is false.',
            '{else command} — The else command is optional. Execute else command if the expression is true.'
          ],
          :result => 'Unchanged if the expression is true. If not true, ' \
            'then the result will be based on the command specified ' \
            "after the 'do'/'then' keyword.",
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

                # 'then' works the same as 'do'
                unless unless.x then show "still false: " + unless.false_msg
          EXAMPLES
        }
      end
    end
  end
end
