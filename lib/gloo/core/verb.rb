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
      # Report any syntax problem in the command's tokens or params
      # (see Tokens#syntax_problem) as a syntax error. The verb still
      # runs afterward, with the tokens' best guess.
      #
      def check_syntax
        [ @tokens, @params ].each do |t|
          problem = t.syntax_problem if t.respond_to?( :syntax_problem )
          @engine.syntax_err problem if problem
        end
      end

      #
      # For a verb that takes no object: whatever was written after it,
      # as one string (empty if nothing was).
      #
      def extra_words
        words = @tokens.respond_to?( :params ) ? @tokens.params.to_a : []
        words += @params.tokens.to_a if @params.respond_to?( :tokens )
        return words.join( ' ' )
      end

      #
      # The verb as written in the command (keyword or shortcut).
      #
      def written_verb
        written = @tokens.verb if @tokens.respond_to?( :verb )
        return written || self.class.keyword
      end

      #
      # For a harmless verb that takes no object: warn if anything was
      # written after it. The verb still runs.
      #
      def warn_extra_words
        extra = extra_words
        return if extra.empty?

        @engine.warn "#{written_verb} takes no object; ignoring '#{extra}'."
      end

      #
      # For a destructive verb that takes no object: if anything was
      # written after it, report an error and return true; the verb
      # should not run. The detail says what didn't happen and what to
      # do instead.
      #
      def extra_words_err?( detail )
        return false if extra_words.empty?

        @engine.err "#{written_verb} takes no object, so #{detail}."
        return true
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
