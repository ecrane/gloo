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
          :description => 'Write to the standard gloo log, or to the gloo error log.',
          :syntax => [ 'log {target} ({level})' ],
          :parameters => [
            '{target} — The message that will be written to the log. ' \
              'The target might be the path to an object, a literal or ' \
              'an expression to be evaluated. Level options are: DEBUG, ' \
              'INFO, WARN, ERROR. Level is an optional parameter — if ' \
              'not specified, the message is written as DEBUG level.'
          ],
          :result => 'The message is written to the log at the ' \
            'specified level. It will contain the log message.',
          :notes => "Use `log clear` from the CLI to clear out both the " \
            "standard log and the error log.\n\n" \
            "> log clear",
          :examples => <<~EXAMPLES.strip
            #
            # Show multiple messages in loggers
            #

            log [can] :
              level [string] : info
              msg [string] : info from var
              on_load [script] :
                log "debug implicit"
                log "debug explicit" (debug)
                log "info" (info)
                log "warn" (warn)
                log "error" (error)
                log log.msg (log.level)
          EXAMPLES
        }
      end

    end
  end
end
