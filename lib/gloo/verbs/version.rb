# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Show the current application version.
#

module Gloo
  module Verbs
    class Version < Gloo::Core::Verb
      
      KEYWORD = 'version'
      KEYWORD_SHORT = 'v'

      # 
      # Run the verb.
      # 
      def run
        $log.show Gloo::App::Info.display_title
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
      
    end
  end
end
