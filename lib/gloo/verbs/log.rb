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
          if is_clear_cmd?
            @engine.log.clear
          else
            write_to_log
          end
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
      # Write to the specified logger.
      # 
      def write_to_log
        expr = Gloo::Expr::Expression.new( @engine, @tokens.params )
        result = expr.evaluate
        level = log_level_specified( result )
        @engine.log.write result, level
        @engine.heap.it.set_to result
      end

      # 
      # Is this a clear logs command?
      # 
      def is_clear_cmd?      
        return true if ( ( @tokens.token_count == 2 ) && 
          ( @tokens.params.first == 'clear' ) )
          
        return false
      end

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
