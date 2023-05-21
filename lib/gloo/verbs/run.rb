# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Run a script.
# Shortcut for telling a script to run.
#

module Gloo
  module Verbs
    class Run < Gloo::Core::Verb

      KEYWORD = 'run'.freeze
      KEYWORD_SHORT = 'r'.freeze
      EVALUATE_RUN = '~>'.freeze
      MISSING_EXPR_ERR = 'Missing Expression!'.freeze

      #
      # Run the verb.
      #
      def run
        if @tokens.token_count < 2
          @engine.err MISSING_EXPR_ERR
          return
        end

        if @tokens.second == EVALUATE_RUN
          run_expression
        else
          run_script
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
      # Run a script specified by pathname
      #
      def run_script
        Gloo::Exec::Runner.run( @engine, @tokens.second )
      end

      #
      # Evaluate an expression and run that.
      #
      def run_expression
        unless @tokens.token_count > 2
          @engine.err MISSING_EXPR_ERR
          return
        end

        expr = Gloo::Expr::Expression.new( @engine, @tokens.params[ 1..-1 ] )
        @engine.parser.run expr.evaluate
      end

    end
  end
end
