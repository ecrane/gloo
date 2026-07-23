# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Set the current context pointer.
# Alternatively if no value is provided, just show the context.
#

module Gloo
  module Verbs
    class Context < Gloo::Core::Verb

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
          :description => 'Get or set the current context. When no ' \
            'parameter is provided, the context will be shown. When the ' \
            "optional path parameter is provided, the context will be set " \
            "to that path. Use 'context root' to set the context back to " \
            'the root level. When context has been set, the pathname can ' \
            'start from the context container by use of the @. prefix.',
          :syntax => [ 'context {path.to.new.context}' ],
          :parameters => [
            '{path.to.new.context} — Optional. The path to the new context when setting the context.'
          ],
          :result => 'Context is optionally set. It will be set to the ' \
            'new context path when we are changing context. Context is ' \
            'shown in either case.',
          :notes => 'Providing a context that does not exist will not ' \
            'initially be a problem — you can set the context to an ' \
            "object before it exists. However, use of a context that " \
            "doesn't exist will be a problem.",
          :examples => <<~EXAMPLES.strip
            context [container] :
              sub [container] :
                msg [string] : Hello Gloo World!
                on_load [script] :
                    @ context.sub
                    show @.msg
                    @ root
          EXAMPLES
        }
      end

    end
  end
end
