# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Execute a shell command.
#

module Gloo
  module Verbs
    class Execute < Gloo::Core::Verb

      KEYWORD = 'execute'.freeze
      KEYWORD_SHORT = 'exec'.freeze
      MISSING_EXPR_ERR = 'Missing Expression!'.freeze

      #
      # Run the verb.
      #
      def run
        if @tokens.token_count < 2
          $engine.err MISSING_EXPR_ERR
          return
        end

        expr = Gloo::Expr::Expression.new( @tokens.params )
        system expr.evaluate, chdir: Dir.pwd
        # `#{expr.evaluate}`
        # exec expr.evaluate
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
