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
          :description => 'Evaluate an expression and put the result ' \
            'into it, without any other action. Unlike put it does ' \
            'not store the result in a named object, and unlike show ' \
            'it does not print it. Primarily used in tests: assert ' \
            'and refute check the value of it, so eval is the bridge ' \
            'for expressions and comparisons that do not already ' \
            'leave a boolean there.',
          :syntax => [ 'eval {expression}' ],
          :parameters => [
            '{expression} — The expression that will be evaluated. The expression is optional. If not provided, eval will result in true.'
          ],
          :result => 'The result of the expression evaluation is put ' \
            'into it. No other action is performed.',
          :examples => <<~EXAMPLES.strip,
            > eval "me"
            > eval "hello " "world"
            > eval 132 * 23
            > eval path.to.num = 1
          EXAMPLES
          :notes => <<~NOTES.strip
            eval was added for the gloo-test framework. assert and refute
            only look at it; the common pattern is to run a verb or
            message, then 'eval it = {expected}' to compare the result to
            an expected value, then assert or refute. Bare eval (or its
            shortcut noop) sets it to true, which pairs with assert for
            'this state should hold' checks.
          NOTES
        }
      end

    end
  end
end
