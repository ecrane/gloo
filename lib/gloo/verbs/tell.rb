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
          :description => 'Send a message to an object, asking it to ' \
            'perform an action. Mechanically identical to the check ' \
            'verb; by convention tell is used to trigger an action ' \
            'or change state, while check is used to investigate ' \
            'state. Using the verb that matches intent makes the ' \
            'code read like natural communication.',
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
          :examples => <<~EXAMPLES.strip,
            > tell an.obj to unload
            > tell the.script to run
            > tell my.str to up
            > tell the.container to count
          EXAMPLES
          :notes => <<~NOTES.strip
            tell and check send the same message the same way — the two
            spellings exist for readability. Use tell for action messages
            (up, inc, run, unload, randomize) and check for state questions
            (blank?, contains?, starts_with?). Either verb will accept
            either kind of message, but mixing them reads wrong:
            'tell my.str for blank?' works but should be a check.
          NOTES
        }
      end

    end
  end
end
