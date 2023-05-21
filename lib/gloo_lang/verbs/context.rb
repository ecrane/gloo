# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Set the current context pointer.
# Alternatively if no value is provided, just show the context.
#

module GlooLang
  module Verbs
    class Context < GlooLang::Core::Verb

      KEYWORD = 'context'.freeze
      KEYWORD_SHORT = '@'.freeze

      #
      # Run the verb.
      #
      def run
        set_context if @tokens.token_count > 1
        show_context
      end

      #
      # Show the current context.
      #
      def show_context
        @engine.log.show "Context:  #{@engine.heap.context}"
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
      # Set the context to the given path.
      #
      def set_context
        path = @tokens.second
        @engine.heap.context.set_to path
        @engine.heap.it.set_to path
        @engine.log.debug "Context set to #{@engine.heap.context}"
      end

    end
  end
end
