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
          :description => 'Send a message to an object. Ask the object ' \
            'to perform an action.',
          :syntax => [ 'tell {path.to.object} to {message}' ],
          :parameters => [
            '{path.to.object} — The object that we want to send a message to.',
            '{message} — The message to send.'
          ],
          :result => 'The result depends on the message that is sent.',
          :errors => [
            "#{UNKNOWN_MSG_ERR} — No message was specified, or the `to` keyword is missing.",
            'Object was not found — The target of the message was not found.'
          ],
          :examples => <<~EXAMPLES.strip
            > tell an.obj to unload
            > tell the.script to run
            > tell my.str to up
            > tell the.container to count
          EXAMPLES
        }
      end

    end
  end
end
