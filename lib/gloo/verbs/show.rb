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

    end
  end
end
