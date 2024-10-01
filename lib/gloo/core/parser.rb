# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# The Parser.
# Can parse single line commands or files.
#

module Gloo
  module Core
    class Parser

      #
      # Set up the parser.
      #
      def initialize( engine )
        @engine = engine
        @engine.log.debug 'parser intialized...'
      end

      #
      # Parse a command from the immediate execution context.
      #
      def parse_immediate( full_cmd )
        # Break the full command into verb and params
        cmd, params = split_params full_cmd

        # Params are the parenthetical part of the command at the end
        params = Gloo::Core::Tokens.new( params ) if params
        tokens = Gloo::Core::Tokens.new( cmd )
        dic = Gloo::Core::Dictionary.instance
        verb = dic.find_verb( tokens.verb )
        return verb.new( @engine, tokens, params ) if verb

        @engine.err "Verb '#{tokens.verb}' was not found."
        return nil
      end

      #
      # If additional params were provided, split them out
      # from the token list.
      #
      def split_params( cmd )
        params = nil
        i = cmd.rindex( '(' )
        if i && cmd.strip.end_with?( ')' )
          pstr = cmd[ i + 1..-1 ]
          params = pstr.strip[ 0..-2 ] if pstr
          cmd = cmd[ 0, i].strip
        end
        return cmd, params
      end

      #
      # Parse a command and then run it if it parsed correctly.
      #
      def run( cmd )
        v = parse_immediate( cmd )
        Gloo::Exec::Runner.go( @engine, v ) if v
      end

    end
  end
end
