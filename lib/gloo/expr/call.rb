# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# An inline function call inside an expression, eg.
# invoke( functions.add 3 4 ) or ~>( functions.add 3 4 ).
#
# Gloo::Core::Tokens recognizes the whole invoke(...)/~>(...) span
# as one token; Call takes that single token, splits it back out
# into a target path and raw arg tokens (reusing Tokens itself, so
# quoted args and nested calls tokenize the same way they would
# anywhere else), and hands both to Gloo::Core::Invoker - the same
# resolve/validate/invoke path the standalone invoke verb uses.
#

module Gloo
  module Expr
    class Call

      attr_reader :target, :arg_tokens

      #
      # Does the given token look like an inline call?
      #
      def self.call?( token )
        return false unless token.is_a?( String )

        return Gloo::Core::Tokens::CALL_OPENERS.any? do |kw|
          token.start_with?( "#{kw}(" ) && token.end_with?( ')' )
        end
      end

      #
      # Parse the call token into a target path and raw arg tokens.
      #
      def initialize( engine, token )
        @engine = engine

        inner = token[ token.index( '(' ) + 1..-2 ].to_s
        tokens = Gloo::Core::Tokens.new( inner )
        @target = tokens.first
        @arg_tokens = tokens.params || []
      end

      #
      # Resolve, validate and invoke - returns the result value, or
      # nil if it failed (an error will already have been reported).
      #
      def value
        return Gloo::Core::Invoker.invoke( @engine, @target, @arg_tokens )
      end

    end
  end
end
