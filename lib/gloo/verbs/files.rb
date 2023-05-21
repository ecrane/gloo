# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# Show all the currently loaded files.
#

module Gloo
  module Verbs
    class Files < Gloo::Core::Verb

      KEYWORD = 'files'.freeze
      KEYWORD_SHORT = 'fs'.freeze

      #
      # Run the verb.
      #
      def run
        return unless @engine.persist_man.maps
        
        @engine.persist_man.maps.each do |map|
          # puts "#{map.obj.name} - #{map.pn}"
          @engine.log.show "#{map.obj.name} - #{map.pn}"
        end
        @engine.heap.it.set_to @engine.persist_man.maps.count
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
