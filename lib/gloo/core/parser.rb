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
      # A trailing (...) is normally the optional-param convention
      # (eg. show "text" (color)) and gets split off here. But a
      # trailing (...) can also be an inline function call that
      # happens to be the last thing in the command (eg.
      # show invoke( functions.add 3 4 )) - that must be left alone
      # so it flows into tokenizing as part of the main command.
      #
      def split_params( cmd )
        i = matching_open_paren_index( cmd )
        return cmd, nil unless i
        return cmd, nil if inline_call_opener?( cmd, i )

        pstr = cmd[ i + 1..-1 ]
        params = pstr.strip[ 0..-2 ] if pstr
        cmd = cmd[ 0, i ].strip
        return cmd, params
      end

      #
      # Find the index of the '(' that balances the command's final
      # ')', counting depth from the end so an inline call earlier
      # in the command (or nested parens) doesn't confuse the match.
      # Returns nil if the command doesn't end with ')', or the
      # parens aren't balanced.
      #
      def matching_open_paren_index( cmd )
        return nil unless cmd.strip.end_with?( ')' )

        depth = 0
        ( cmd.length - 1 ).downto( 0 ) do |idx|
          case cmd[ idx ]
          when ')' then depth += 1
          when '('
            depth -= 1
            return idx if depth.zero?
          end
        end
        return nil
      end

      #
      # Is the '(' at the given index immediately preceded (no
      # space) by an inline-call keyword, eg. invoke( or ~>( ?
      # Shares its keyword list with Gloo::Core::Tokens, which is
      # where such a call actually gets recognized as one token.
      #
      def inline_call_opener?( cmd, paren_index )
        before = cmd[ 0...paren_index ]
        word = before[ /\S*\z/ ]
        return Gloo::Core::Tokens::CALL_OPENERS.include?( word )
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
