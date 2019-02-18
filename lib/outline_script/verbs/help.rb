# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Show the help information.
#

module OutlineScript
  module Verbs
    class Help < OutlineScript::Core::Verb
      
      # 
      # Run the verb.
      # 
      def run
        $engine.run_help( true )
      end
      
      # 
      # Get the Verb's keyword.
      # 
      def self.keyword
        return 'help'
      end

      # 
      # Get the Verb's keyword shortcut.
      # 
      def self.keyword_shortcut
        return '?'
      end

    end
  end
end
