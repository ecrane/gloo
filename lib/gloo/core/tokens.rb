# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An ordered list of tokens.
# The list of tokens makes up a command.
#

module Gloo
  module Core
    class Tokens

      # Keywords that open an inline function call, eg. invoke( ... )
      # or ~>( ... ). Kept here since Tokens is where they get
      # recognized as a single bounded token; Parser#split_params
      # reuses this same list to avoid mistaking a trailing call for
      # its unrelated trailing-optional-param convention.
      CALL_OPENERS = %w[invoke ~>].freeze

      QUOTE_CHARS = [ '"', "'" ].freeze

      attr_reader :cmd, :tokens

      # ---------------------------------------------------------------------
      #    Constructor
      # ---------------------------------------------------------------------

      #
      # Set up the tokens.
      # The command string is parsed into tokens during creation.
      #
      def initialize( cmd_string )
        @cmd = cmd_string
        @tokens = []
        tokenize @cmd
      end

      # ---------------------------------------------------------------------
      #    Public functions
      # ---------------------------------------------------------------------

      #
      # Get the number of tokens
      #
      def token_count
        return @tokens.size
      end

      #
      # Get the verb (the first word)
      #
      def verb
        return first
      end

      #
      # Get all tokens except the first.
      #
      def params
        return @tokens[ 1..-1 ]
      end

      #
      # Get the first token.
      #
      def first
        return @tokens.first if @tokens
      end

      #
      # Get the last token.
      #
      def last
        return @tokens.last if @tokens
      end

      #
      # Get the second token.
      #
      def second
        return @tokens[ 1 ] if @tokens&.size&.positive?
      end

      #
      # Get the token at the the requested index.
      #
      def at( index )
        return @tokens[ index ] if @tokens && @tokens.size >= index
      end

      #
      # Get the index of the given token.
      #
      def index_of( token )
        return nil unless @tokens

        return @tokens.find_index { |o| o.casecmp( token ).zero? }
      end

      #
      # Get the list of tokens after the given token
      #
      def tokens_after( token )
        i = index_of token
        return @tokens[ i + 1..-1 ] if i && @tokens && @tokens.size > ( i + 1 )

        return nil
      end

      #
      # Get the expression after the given token
      #
      def expr_after( token, break_token = nil )
        str = ''
        token_list = tokens_after( token )
        return str if token_list.nil?

        token_list.each do |t|
          str << ' ' unless str.empty?
          break if t == break_token
          str << t.to_s
        end
        return str
      end

      #
      # Get the item after a given token.
      #
      def after_token( token )
        i = index_of token
        return @tokens[ i + 1 ] if i && @tokens && @tokens.size > ( i + 1 )

        return nil
      end

      #
      # Get the item after a given token.
      #
      def before_token( token )
        i = index_of token
        return @tokens[ 0..i - 1 ] if i && @tokens && @tokens.size >= i

        return nil
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Create a list of token from the given string.
      #
      # An inline call (invoke( ... ) / ~>( ... )) is checked for
      # first since it needs to be quote-aware in its own right (a
      # call's args can include a quoted string) - see
      # find_call_range. Falls through to the original quote-then-
      # plain-split handling, unchanged, when there's no call.
      #
      def tokenize( str )
        range = find_call_range( str )
        if range
          tokenize( str[ 0...range.first ] ) if range.first.positive?
          @tokens << str[ range ]
          tokenize( str[ range.last + 1..-1 ] ) if range.last + 1 < str.length
        elsif str.index( '"' )
          i = str.index( '"' )
          j = str.index( '"', i + 1 )
          j ||= str.length

          tokenize( str[ 0..i - 1 ] ) if i > 1
          @tokens << str[ i..j ]
          tokenize( str[ j + 1..-1 ] ) if j + 1 < str.length
        elsif str.index( "'" )
          i = str.index( "'" )
          j = str.index( "'", i + 1 )
          j ||= str.length

          tokenize( str[ 0..i - 1 ] ) if i > 1
          @tokens << str[ i..j ]
          tokenize( str[ j + 1..-1 ] ) if j + 1 < str.length
        else
          str.strip.split( ' ' ).each { |t| @tokens << t }
        end
      end

      #
      # Find the char range of the first top-level (not inside a
      # quoted string) invoke(...)/~>(...) call in str. Returns nil
      # if there isn't one, or it's never properly closed.
      #
      def find_call_range( str )
        i = 0
        while i < str.length
          ch = str[ i ]

          if QUOTE_CHARS.include?( ch )
            close = str.index( ch, i + 1 )
            return nil unless close

            i = close + 1
            next
          end

          CALL_OPENERS.each do |kw|
            opener = "#{kw}("
            next unless str[ i, opener.length ] == opener
            next unless i.zero? || str[ i - 1 ] =~ /\s/

            close = find_matching_close_paren( str, i + opener.length - 1 )
            return ( i..close ) if close
          end

          i += 1
        end
        return nil
      end

      #
      # Given the index of an open paren, find the index of its
      # balancing close paren - skipping over quoted substrings so
      # a stray paren character inside a quoted arg doesn't throw
      # off the depth count. Returns nil if it's never closed.
      #
      def find_matching_close_paren( str, open_index )
        depth = 0
        i = open_index
        while i < str.length
          ch = str[ i ]
          if QUOTE_CHARS.include?( ch )
            close = str.index( ch, i + 1 )
            return nil unless close

            i = close + 1
            next
          elsif ch == '('
            depth += 1
          elsif ch == ')'
            depth -= 1
            return i if depth.zero?
          end
          i += 1
        end
        return nil
      end

    end
  end
end
