# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Deliberately raise a Ruby exception, to exercise the on_exception
# handling pipeline (eg. for testing).
#

module Gloo
  module Verbs
    class Throw < Gloo::Core::Verb

      KEYWORD = 'throw'.freeze
      KEYWORD_SHORT = 'throw'.freeze
      DEFAULT_MSG = 'Thrown by throw verb'.freeze

      #
      # Run the verb.
      #
      def run
        raise message
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
      # Get the message to throw, evaluating an expression if one is given.
      #
      def message
        return DEFAULT_MSG unless @tokens.params&.any?

        expr = Gloo::Expr::Expression.new( @engine, @tokens.params )
        return expr.evaluate
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
          :description => 'Deliberately raise a Ruby exception, to ' \
            'exercise the on_exception handling pipeline (e.g. for ' \
            'testing). Execution continues normally after the throw — ' \
            'it is not a fatal halt.',
          :syntax => [ 'throw {optional message}' ],
          :parameters => [
            "{message} — Optional. An expression evaluated and used as the thrown message. If not provided, a default message (\"#{DEFAULT_MSG}\") is used."
          ],
          :result => "Fires the app's on_exception handler, if one is " \
            'defined, with exception_data.message set to the thrown ' \
            'message. Does not fire on_error.',
          :examples => <<~EXAMPLES.strip
            > throw
            > throw "custom message"
          EXAMPLES
        }
      end

    end
  end
end
