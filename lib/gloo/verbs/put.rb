# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Create an object, optionally of a type.
#

module Gloo
  module Verbs
    class Put < Gloo::Core::Verb

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
        pn = Gloo::Core::Pn.new( @engine, target )
        o = pn.resolve
        if o.nil?
          @engine.err "#{TARGET_ERR} #{target}"
        elsif value.count.positive?
          expr = Gloo::Expr::Expression.new( @engine, value )
          result = expr.evaluate
          o.set_value result
          @engine.heap.it.set_to result
        end
      end

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
          :description => 'Put a value into an object. ' \
            'The value is the result of an expression.',
          :syntax => [ 'put {expression} into {dst.path}' ],
          :parameters => [
            '{expression} — The expression that is evaluated.',
            '{dst.path} — The path to the destination object.'
          ],
          :result => 'The destination object has the result of the ' \
            'evaluated expression. It will also be set into it.',
          :errors => [
            "#{MISSING_EXPR_ERR} — The into keyword is missing, or no source expression is provided.",
            "#{INTO_MISSING_ERR} — The destination is not specified.",
            "#{TARGET_ERR}{dst.path} — The destination of the put cannot be resolved."
          ],
          :examples => <<~EXAMPLES.strip
            > put 'one' into str
            > put "two" into str
            > put 123 into x
            > put 3 + 5 into x
            > put TRUE into flag
          EXAMPLES
        }
      end

    end
  end
end
