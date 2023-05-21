# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Create an object, optionally of a type.
#

module Gloo
  module Verbs
    class Put < GlooLang::Core::Verb

      KEYWORD = 'put'.freeze
      KEYWORD_SHORT = 'p'.freeze
      INTO = 'into'.freeze
      MISSING_EXPR_ERR = 'Missing Expression!'.freeze
      INTO_MISSING_ERR = 'Target (into) missing!'.freeze
      TARGET_ERR = 'Target could not be resolved: '.freeze

      #
      # Run the verb.
      #
      def run
        value = fetch_value_tokens
        return if value.nil?

        target = lookup_target
        return if target.nil?

        update_target target, value
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
      # Get the value that is being put.
      #
      def fetch_value_tokens
        value = @tokens.before_token( INTO )
        if value.nil? || ( value.count <= 1 )
          @engine.err MISSING_EXPR_ERR
          return nil
        end

        # The first token is the verb, so we drop it.
        return value[ 1..-1 ]
      end

      #
      # Lookup the target of the put command.
      #
      def lookup_target
        target = @tokens.after_token( INTO )
        return target if target

        @engine.err INTO_MISSING_ERR
        return nil
      end

      #
      # Update the target with the new value.
      #
      def update_target( target, value )
        pn = GlooLang::Core::Pn.new( @engine, target )
        o = pn.resolve
        if o.nil?
          @engine.err "#{TARGET_ERR} #{target}"
        elsif value.count.positive?
          expr = GlooLang::Expr::Expression.new( @engine, value )
          result = expr.evaluate
          o.set_value result
          @engine.heap.it.set_to result
        end
      end

    end
  end
end
