# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Invoke a function from a script.
#
# Resolution, validation and the actual invoke are all handled by
# Gloo::Core::Invoker, shared with inline calls inside expressions
# (see Gloo::Expr::Call) so both go through the same error handling.
#

module Gloo
  module Verbs
    class Invoke < Gloo::Core::Verb

      KEYWORD = 'invoke'.freeze
      KEYWORD_SHORT = '~>'.freeze

      #
      # Run the verb.
      #
      def run
        target = @tokens.token_count > 1 ? @tokens.second : nil
        arg_tokens = @tokens.token_count > 1 ? @tokens.params[ 1..-1 ] : []

        return Gloo::Core::Invoker.invoke( @engine, target, arg_tokens )
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
      #    Verb Documentation
      # ---------------------------------------------------------------------

      #
      # Get the verb's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Invoke a function. Set it to the result of the function.',
          :syntax => [
            'invoke {path.to.function} {params}',
            'invoke( {path.to.function} {params} )  — inline, usable inside any expression',
            '~>( {path.to.function} {params} )      — inline, shortcut spelling'
          ],
          :parameters => [
            '{path.to.function} — The function we want to invoke.',
            '{params} — The list of parameters to the function.'
          ],
          :result => 'The result of the function is put into it. The ' \
            'inline forms (invoke(...), ~>(...)) can be used anywhere ' \
            'an expression is evaluated - show, put ... into, if, ' \
            'unless, eval, and more - and evaluate to the result ' \
            'directly rather than going through it.',
          :errors => [
            "#{Gloo::Core::Invoker::NO_TARGET_ERR} — No function reference was given.",
            "#{Gloo::Core::Invoker::NOT_FOUND_ERR}{path.to.function} — The path doesn't resolve to any object.",
            "#{Gloo::Core::Invoker::NOT_FUNCTION_ERR}{path.to.function} — The path resolves to an object that isn't a function.",
            "#{Gloo::Core::Invoker::PARAM_COUNT_ERR}{path.to.function} (expected N, got N) — The number of params given doesn't match what the function declares."
          ],
          :notes => 'If the function itself fails during invocation ' \
            '(its on_invoke script hits an error), it is left ' \
            'unchanged rather than being set to an unreliable result. ' \
            'The underlying error is whatever was reported by the ' \
            'failure inside the function. ' \
            'Inline call params are space-separated, same as the ' \
            'standalone verb - each one is evaluated as a single ' \
            'token (a literal or object reference), not a multi-token ' \
            "sub-expression, so invoke( f 3+4 ) won't parse 3+4 as " \
            'one arg.',
          :examples => <<~EXAMPLES.strip
            #
            # Function examples
            #

            functions [can] :

              name [string] : Jasper

              on_load [script] :
                show 'running function examples' (white)

                invoke functions.greet ^.name
                show it

                invoke functions.add 3 4
                show it

                # Inline, anywhere an expression is evaluated:
                show invoke( functions.add 3 4 )
                put ~>( functions.add 3 4 ) into total
                show "Total: " + invoke( functions.add 3 4 )

                show 'done' (white)

              #
              # Say hi to person (name)
              #
              greet [ƒ] :
                on_invoke [script] :
                  put 'Hi, ' + ^.params.name into ^.result
                params [container] :
                  name [string] : none
                result [string] :

              #
              # Add 2 numbers
              #
              add [ƒ] :
                on_invoke [script] :
                  put ^.params.x and ^.params.y into ^.result
                params [container] :
                  x [int] :
                  y [int] :
                result [string] :
          EXAMPLES
        }
      end

    end
  end
end
