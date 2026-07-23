# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Invoke a function from a script.
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
        if @tokens.token_count > 1
          ob = @tokens.first

          # Get the function object
          pn = Gloo::Core::Pn.new( @engine, @tokens.second ) 
          func = pn.resolve

          # Is the object a function?
          if func&.is_function?
            params = get_params_arr
          
            @engine.log.debug "invoking function: #{func.pn}"
            result = func.invoke( params ) 
            @engine.log.debug "function returned: #{result}"
            @engine.heap.it.set_to result
            return result
          end
        end
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
      # Get params array.
      #
      def get_params_arr
        @engine.log.debug "token params: #{@tokens.params}"
        params = @tokens.params[1..-1]

        @engine.log.info "params: #{params}"
        evaluated_params = []

        params.each do |p|
          expr = Gloo::Expr::Expression.new( @engine, [ p ] )
          evaluated_params << expr.evaluate
        end

        @engine.log.debug "evaluated_params: #{evaluated_params}"

        return evaluated_params
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
          :syntax => [ 'invoke {path.to.function} {params}' ],
          :parameters => [
            '{path.to.function} — The function we want to invoke.',
            '{params} — The list of parameters to the function.'
          ],
          :result => 'The result of the function is put into it.',
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
