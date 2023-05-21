# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Wait for the given number of seconds.
#

module GlooLang
  module Verbs
    class Wait < GlooLang::Core::Verb

      KEYWORD = 'wait'.freeze
      KEYWORD_SHORT = 'w'.freeze

      #
      # Run the verb.
      #
      def run
        x = 1
        if @tokens.token_count > 1
          expr = GlooLang::Expr::Expression.new( @engine, @tokens.params )
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

    end
  end
end
