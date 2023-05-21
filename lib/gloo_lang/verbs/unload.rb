# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# Unload all files.
#

module GlooLang
  module Verbs
    class Unload < GlooLang::Core::Verb

      KEYWORD = 'unload'.freeze
      KEYWORD_SHORT = 'u!'.freeze

      #
      # Run the verb.
      #
      def run
        return unless @engine.persist_man.maps
        
        objs = @engine.persist_man.maps.map { |fs| fs.obj }
        objs.each { |o| o.msg_unload }
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
