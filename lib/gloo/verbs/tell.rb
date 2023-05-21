# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Create an object, optionally of a type.
#

module Gloo
  module Verbs
    class Tell < GlooLang::Core::Verb

      KEYWORD = 'tell'.freeze
      KEYWORD_SHORT = '->'.freeze
      TO = 'to'.freeze
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
        @msg = @tokens.after_token( TO )

        @engine.err( UNKNOWN_MSG_ERR ) unless @msg
      end

      #
      # Setup the target of the message.
      #
      def setup_target
        @obj_name = @tokens.second
        pn = GlooLang::Core::Pn.new( @engine, @obj_name )
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
