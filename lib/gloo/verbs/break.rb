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
          :description => 'Break out of the current script, stop running.',
          :syntax => [ 'break' ],
          :result => 'No more commands are executed in the currently ' \
            'running script. If there are other scripts in the stack, ' \
            'they will resume normally.',
          :examples => <<~EXAMPLES.strip
            #
            # Break out of a script.
            #
            break_out [can] :
              x [bool] : false
              on_load [script] :
                if ^.x then break
                show 'should see this'
                put true into ^.x
                if ^.x then break
                show 'should not see this'
          EXAMPLES
        }
      end

    end
  end
end
