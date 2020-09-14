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

      #
      # Run the verb.
      #
      def run
        return unless @tokens.token_count > 1

        expr = Gloo::Expr::Expression.new( @tokens.params )
        result = expr.evaluate
        $engine.heap.it.set_to result
        self.post_alert result
      end

      #
      # Post the alert for the specific platform.
      # Notice is not posted if we're in quiet mode.
      #
      def post_alert( msg )
        return if $engine.args.quiet?

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
