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
      OBJ_NOT_FOUND_ERR = 'Object was not found: '.freeze
      UNKNOWN_MSG_ERR = 'Missing message!'.freeze

      #
      # Run the verb.
      #
      def run
        setup_msg
        return unless @msg

        setup_target
        dispatch_msg
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
      # Lookup the message to send.
      #
      def setup_msg
        @msg = @tokens.after_token( FOR )

        @engine.err( UNKNOWN_MSG_ERR ) unless @msg
      end

      #
      # Setup the target of the message.
      #
      def setup_target
        @obj_name = @tokens.second
        pn = Gloo::Core::Pn.new( @engine, @obj_name )
        @target_obj = pn.resolve
      end

      #
      # Dispatch the message to the target object.
      #
      def dispatch_msg
        if @target_obj
          Gloo::Exec::Dispatch.message(
            @engine, @msg, @target_obj, @params )
        else
          @engine.err "#{OBJ_NOT_FOUND_ERR} #{@obj_name}"
        end
      end

    end
  end
end
