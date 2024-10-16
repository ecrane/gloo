# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Alternate version of the Tell verb.
# Reads better to check object conditions.
#

module Gloo
  module Verbs
    class Check < Gloo::Core::Verb

      KEYWORD = 'check'.freeze
      KEYWORD_SHORT = '<-'.freeze
      FOR = 'for'.freeze
      UNKNOWN_MSG_ERR = 'Missing message!'.freeze

      #
      # Run the verb.
      #
      def run
        msg = @tokens.after_token( FOR )

        unless msg
          @engine.err( UNKNOWN_MSG_ERR ) 
          return
        end

        Gloo::Exec::Dispatch.send_message(
          @engine, msg, @tokens.second, @params )
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
