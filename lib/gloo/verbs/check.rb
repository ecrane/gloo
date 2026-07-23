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
          :description => 'Send a message to an object to check for an ' \
            'object condition. This is the same as the tell verb, but ' \
            'gives better syntactical naming.',
          :syntax => [ 'check {path.to.object} for {condition_message}' ],
          :parameters => [
            '{path.to.object} — The object that we want to send a condition_message to.',
            '{message} — The condition_message to send.'
          ],
          :result => 'The result depends on the message that is sent, but ' \
            'by convention the result of the check will be in it.',
          :errors => [
            "#{UNKNOWN_MSG_ERR} — No message was specified, or the 'for' keyword is missing.",
            'Object was not found — The target of the message was not found.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Base object checks.
            #
            obj [container] :
              msg [string] :
              on_load [script] :
                show 'Does the obj container have children?'
                check obj for contains?
                show it

                show 'Is the msg blank?'
                check obj.msg for blank?
                show it

                put 'Hello, world!' into obj.msg
                show obj.msg
                show 'Is the msg still blank?'
                check obj.msg for blank?
                show it
          EXAMPLES
        }
      end

    end
  end
end
