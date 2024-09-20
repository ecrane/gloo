# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Show the current application version.
#

module Gloo
  module Verbs
    class Version < Gloo::Core::Verb

      KEYWORD = 'version'.freeze
      KEYWORD_SHORT = 'v'.freeze
      NOTES = 'notes'.freeze
      NOTES_SHORT = 'n'.freeze

      #
      # Run the verb.
      #
      def run
        vers_notes? ? show_vers_notes : show_vers
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
      # Show basic version numbers.
      # 
      def show_vers
        @engine.log.show Gloo::App::Info.full_version
        @engine.log.show "\nUse `#{KEYWORD} #{NOTES}` to see version notes."
      end

      # 
      # Show version notes.
      # 
      def show_vers_notes
        @engine.log.show "Gloo version notes..."
        notes = Gloo::App::Info.get_version_notes
        @engine.platform.show notes
      end

      # 
      # Is the request to show version notes?
      # 
      def vers_notes?
        if ( @tokens.token_count > 1 ) && ( 
          ( @tokens.last == NOTES ) || ( @tokens.last == NOTES_SHORT ) )
          return true
        end

        return false
      end

    end
  end
end
