# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2023 Eric Crane.  All rights reserved.
#
# Write to the standard (or error) gloo log.
#

module Gloo
  module Verbs
    class Log < Gloo::Core::Verb

      KEYWORD = 'log'.freeze
      KEYWORD_SHORT = 'log'.freeze

      #
      # Run the verb.
      #
      def run
        if @tokens.token_count > 1
          expr = Gloo::Expr::Expression.new( @engine, @tokens.params )
          result = expr.evaluate
          level = log_level_specified( result )
          @engine.log.write result, level
          @engine.heap.it.set_to result
        else
          @engine.log.debug ''
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
      def log_level_specified( str )
        if @params&.token_count&.positive?
          if Gloo::App::Log.is_level? @params.tokens.first
            return @params.tokens.first
          end

          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          level = expr.evaluate
          return level if Gloo::App::Log.is_level? level
        end

        # Lastly, it's just debug
        return Gloo::App::Log::LEVELS[0]
      end

    end
  end
end
