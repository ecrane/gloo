# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Redirect the web svr request to a different page.
# This verb only works in context of a running web server.
#

module Gloo
  module Verbs
    class Redirect < Gloo::Core::Verb

      KEYWORD = 'redirect'.freeze
      KEYWORD_SHORT = 'go'.freeze

      MISSING_EXPR_ERR = 'Missing Expression!'.freeze

      #
      # Run the verb.
      #
      def run
        if @tokens.token_count < 2
          @engine.err MISSING_EXPR_ERR
          return
        end

        # Send the redirect page to the running app.
        if @engine.app_running?
          obj_name = @tokens.second
          pn = Gloo::Core::Pn.new( @engine, obj_name )
          @engine.running_app.obj.redirect = pn.resolve
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

    end
  end
end
