# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Show a system notification.
#

module Gloo
  module Verbs
    class Alert < Gloo::Core::Verb

      KEYWORD = 'alert'.freeze
      KEYWORD_SHORT = '!'.freeze

      MISSING_EXPR_ERR = 'Missing Expression!'.freeze
      NO_RESULT_ERR = 'Expression evaluated with no result!'.freeze

      #
      # Run the verb.
      #
      def run
        unless @tokens.token_count > 1
          @engine.err MISSING_EXPR_ERR
          return
        end

        expr = Gloo::Expr::Expression.new( @engine, @tokens.params )
        result = expr.evaluate

        if result
          @engine.heap.it.set_to result
          post_alert result
        else
          @engine.err NO_RESULT_ERR
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
      # Post the alert for the specific platform.
      # Notice is not posted if we're in quiet mode.
      #
      def post_alert( msg )
        @engine.log.info msg
        return if @engine.args.quiet?

        post_osx msg
      end

      #
      # Post the alert on the Mac OSX.
      #
      def post_osx( msg )
        cmd1 = '/usr/bin/osascript -e "display notification \"'
        cmd2 = '\" with title \"Gloo\" "'
        system( cmd1 + msg.to_s + cmd2 )
      end

    end
  end
end
