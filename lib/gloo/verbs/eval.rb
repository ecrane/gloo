# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Evaluate an expression and put the result into [it].
#

module Gloo
  module Verbs
    class Eval < Gloo::Core::Verb

      KEYWORD = 'eval'.freeze
      KEYWORD_SHORT = 'noop'.freeze

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

      #
      # Run the verb.
      #
      def run
        if @tokens.token_count > 1
          expr = Gloo::Expr::Expression.new( @engine, @tokens.params )
          result = expr.evaluate
          @engine.heap.it.set_to result
        else
          @engine.heap.it.set_to true
        end
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
          :description => 'Evaluate an expression and put the result into it.',
          :syntax => [ 'eval {expression}' ],
          :parameters => [
            '{expression} — The expression that will be evaluated. The expression is optional. If not provided, eval will result in true.'
          ],
          :result => 'The result of the expression evaluation is put ' \
            'into it. No other action is performed.',
          :examples => <<~EXAMPLES.strip
            > eval "me"
            > eval "hello " "world"
            > eval 132 * 23
            > eval path.to.num = 1
          EXAMPLES
        }
      end

    end
  end
end
