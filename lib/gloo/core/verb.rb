# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An abstract base verb.
# Derives from the Baseo object.
# It is a special type of object in that it can be run
# and can perform an action.
#

module Gloo
  module Core
    class Verb < Baseo

      attr_reader :tokens, :params

      #
      # Set up the verb.
      #
      def initialize( engine, tokens, params = [] )
        @engine = engine
        @tokens = tokens
        @params = params
      end

      #
      # Register verbs when they are loaded.
      #
      def self.inherited( subclass )
        Dictionary.instance.register_verb( subclass )
      end

      #
      # Run the verb.
      #
      # We'll mark the application as not running and let the
      # engine stop gracefully next time through the loop.
      #
      def run
        raise 'this method should be overriden'
      end

      #
      # Get the Verb's keyword.
      #
      # The keyword will be in lower case only.
      # It is used by the parser.
      #
      def self.keyword
        raise 'this method should be overriden'
      end

      #
      # Get the Verb's keyword shortcut.
      #
      def self.keyword_shortcut
        raise 'this method should be overriden'
      end

      #
      # The object type, suitable for display.
      #
      def type_display
        return self.class.keyword
      end

      #
      # Generic function to get display value.
      # Can be used for debugging, etc.
      #
      def display_value
        return self.class.keyword
      end

      # ---------------------------------------------------------------------
      #    Help
      # ---------------------------------------------------------------------

      #
      # Get help for this verb.
      #
      def self.help
        return 'No help found.'
      end

    end
  end
end
