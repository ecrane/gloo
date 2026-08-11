# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Resolves, validates and invokes a function. Shared by the
# `invoke`/`~>` verb (lib/gloo/verbs/invoke.rb) and inline calls
# inside any expression (lib/gloo/expr/call.rb), so both go through
# the same error handling instead of maintaining two copies of it.
#

module Gloo
  module Core
    class Invoker

      NO_TARGET_ERR = 'Missing function reference!'.freeze
      NOT_FOUND_ERR = 'Object was not found: '.freeze
      NOT_FUNCTION_ERR = 'Not a function: '.freeze
      PARAM_COUNT_ERR = 'Wrong number of parameters for function: '.freeze

      #
      # Resolve, validate and invoke the function at the given
      # target path, with the given raw (unevaluated) arg tokens.
      # Reports an error and returns nil for any failure - including
      # a failure inside the function itself (see Function#invoke,
      # which leaves `it` alone rather than setting it to an
      # unreliable result when that happens).
      #
      def self.invoke( engine, target, arg_tokens )
        if target.nil? || target.to_s.strip.empty?
          engine.err NO_TARGET_ERR
          return nil
        end

        func = resolve_function( engine, target )
        return nil unless func

        args = evaluate_arg_tokens( engine, arg_tokens )
        return nil unless params_count_ok?( engine, func, args )

        return invoke_function( engine, func, args )
      end

      #
      # Resolve the function object at the target path. Reports an
      # error and returns nil if the path doesn't resolve to
      # anything, or resolves to an object that isn't a function.
      #
      def self.resolve_function( engine, target )
        pn = Gloo::Core::Pn.new( engine, target )
        func = pn.resolve

        unless func
          engine.err "#{NOT_FOUND_ERR}#{target}"
          return nil
        end

        unless func.is_function?
          engine.err "#{NOT_FUNCTION_ERR}#{target}"
          return nil
        end

        return func
      end

      #
      # Evaluate a list of raw tokens, each as its own single-token
      # expression (a literal or object reference) - the standalone
      # invoke verb's long-standing per-token semantics, now shared
      # with the inline-call form too.
      #
      def self.evaluate_arg_tokens( engine, tokens )
        return ( tokens || [] ).map do |t|
          Gloo::Expr::Expression.new( engine, [ t ] ).evaluate
        end
      end

      #
      # Confirm the number of args given matches the number the
      # function declares. Reports an error and returns false if
      # they don't match.
      #
      def self.params_count_ok?( engine, func, args )
        expected = func.params_hash&.keys&.length || 0
        return true if args.count == expected

        engine.err "#{PARAM_COUNT_ERR}#{func.pn} " \
          "(expected #{expected}, got #{args.count})"
        return false
      end

      #
      # Invoke the function and return its result.
      #
      def self.invoke_function( engine, func, args )
        engine.log.debug "invoking function: #{func.pn}"
        result = func.invoke( args )
        engine.log.debug "function returned: #{result}"
        return result
      end

    end
  end
end
