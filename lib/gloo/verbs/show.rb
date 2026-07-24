# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Show a single object's value.
#

module Gloo
  module Verbs
    class Show < Gloo::Core::Verb

      KEYWORD = 'show'.freeze
      KEYWORD_SHORT = 'print'.freeze

      #
      # Run the verb.
      #
      def run
        if @tokens.token_count > 1
          expr = Gloo::Expr::Expression.new( @engine, @tokens.params )
          result = expr.evaluate
          @engine.log.show get_formatted_string( result )
          @engine.heap.it.set_to result
        else
          @engine.log.show ''
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
      # Get the formatted string.
      #
      def get_formatted_string( str )
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          val = expr.evaluate
          color = val.to_sym
          return @engine.platform.get_colorized_string( str, color )
        end
        return str
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
          :description => "Show an object's value, a literal or the " \
            'result of an evaluation.',
          :syntax => [
            'show {target}',
            'show {target} ({color})'
          ],
          :parameters => [
            '{target} — The object that we want to see. The target ' \
              'might be the path to an object, a literal or an ' \
              'expression to be evaluated before being shown.',
            '{color} — Optional color for the text.'
          ],
          :result => "The object's value is shown, or the literal, or " \
            'the result of the evaluated expression is shown. It will ' \
            "contain the object's value.",
          :examples => <<~EXAMPLES.strip,
            > show "me"
            > show "hello " "world"
            > show 132 * 23

            > create x : "boo"
            > show x
          EXAMPLES
          :notes => <<~NOTES.strip
            Example with Color:

            #
            # Show multiple messages in color
            #

            colors [can] :
              var [string] : red
              on_load [script] :
                show "red" (colors.var)
                show "blue" (blue)
                show "green" (green)
                show "white" (white)
                show "black" (black)
                show "yellow" (yellow)
          NOTES
        }
      end

    end
  end
end
