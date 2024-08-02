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

    end
  end
end
