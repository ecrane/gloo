# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Break out of the script without error.
#

module Gloo
  module Verbs
    class Break < Gloo::Core::Verb

      KEYWORD = 'break'.freeze
      KEYWORD_SHORT = 'stop'.freeze

      #
      # Run the verb.
      # Stop the execution of the current script.
      #
      def run
        @engine.exec_env.running_script.break_out
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
