# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Show the help information.
#

module Gloo
  module Verbs
    class Help < GlooLang::Core::Verb

      KEYWORD = 'help'.freeze
      KEYWORD_SHORT = '?'.freeze
      DEFAULT_HELP = 'default_help'.freeze
      HELP_NOT_FOUND_ERR = 'Help command could not be found:'.freeze

      DISPATCH = {
        settings: 'show_settings',
        keywords: 'show_keywords',
        verb: 'show_verbs',
        verbs: 'show_verbs',
        v: 'show_verbs',
        obj: 'show_objs',
        object: 'show_objs',
        objects: 'show_objs',
        o: 'show_objs',
        topics: 'show_topics'
      }.freeze

      #
      # Run the verb.
      #
      def run
        data = "\n For documentation use the gloo website. \n\n"
        @engine.log.show data
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
      # Write output to it and show it unless we are in
      # silent mode.
      #
      def show_output( out )
        @engine.heap.it.set_to out
        puts out unless @engine.args.quiet?
      end

      #
      # Show application settings.
      #
      def show_settings
        @engine.settings.show
      end

      #
      # Show all keywords: verbs and objects.
      #
      def show_keywords
        @engine.dictionary.show_keywords
      end

    end
  end
end
