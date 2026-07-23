# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Wait for the given number of seconds.
#

module Gloo
  module Verbs
    class Wait < Gloo::Core::Verb

      KEYWORD = 'wait'.freeze
      KEYWORD_SHORT = 'w'.freeze

      #
      # Run the verb.
      #
      def run
        x = 1
        if @tokens.token_count > 1
          expr = Gloo::Expr::Expression.new( @engine, @tokens.params )
          x = expr.evaluate.to_i
        end
        sleep x
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
      #    Verb Documentation
      # ---------------------------------------------------------------------

      #
      # Get the verb's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Wait for the given number of seconds.',
          :syntax => [ 'wait {seconds}' ],
          :parameters => [
            '{seconds} — The number of seconds to wait. Optional. If no value is given, we will wait for 1 second.'
          ],
          :examples => <<~EXAMPLES.strip
            > wait
            > wait 3

            > create x as int : 10
            > wait x
          EXAMPLES
        }
      end

    end
  end
end
