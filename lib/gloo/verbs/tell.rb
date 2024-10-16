# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Send a message to an object.
# Tell the object to do some known action.
# Also see the Check verb.
#

module Gloo
  module Verbs
    class Tell < Gloo::Core::Verb

      KEYWORD = 'tell'.freeze
      KEYWORD_SHORT = '->'.freeze
      TO = 'to'.freeze
      UNKNOWN_MSG_ERR = 'Missing message!'.freeze

      #
      # Run the verb.
      #
      def run
        msg = @tokens.after_token( TO )

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
