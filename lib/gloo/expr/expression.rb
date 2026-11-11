# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An Expression that can be evaluated.
#

module Gloo
  module Expr
    class Expression

      DIVIDE_BY_ZERO_ERR = 'Division by zero.'.freeze
      EMPTY_GROUP_ERR = 'Empty parentheses.'.freeze
      OPEN_PAREN = '('.freeze
      CLOSE_PAREN = ')'.freeze

      # ---------------------------------------------------------------------
      #    Constructor
      # ---------------------------------------------------------------------

      #
      # Create the expression from a list of tokens.
      #
      def initialize( engine, tokens )
        @engine = engine
        @tokens = tokens
        @symbols = []
        @left = nil
        @right = nil
        @op = nil
      end

      # ---------------------------------------------------------------------
      #    Evaluate Expression
      # ---------------------------------------------------------------------

      #
      # Evaluate the expression and return the value.
      #
      def evaluate
        identify_tokens

        @symbols.each do |sym|
          if sym.is_a? Gloo::Core::Op
            missing_value( @op ) if @op
            @op = sym
          elsif @left.nil?
            @left = sym
          else
            @right = sym
          end

          perform_op if @left && @right
        end
        missing_value( @op ) if @op

        return evaluate_sym( @left )
      end

      #
      # Split grouping parentheses off the tokens, so each is a token
      # of its own: '(3' and '4)' become '(' '3' and '4' ')'. Quoted
      # text and inline calls (invoke( ... )) are left whole.
      #
      def self.split_parens( tokens )
        return tokens.flat_map do |t|
          next [ t ] unless t.is_a?( String )
          next [ t ] if Gloo::Core::Tokens::QUOTE_CHARS.include?( t[ 0 ] )
          next [ t ] if Gloo::Expr::Call.call?( t )

          split_paren_token( t )
        end
      end

      #
      # Split the leading '(' and trailing ')' off one token.
      #
      def self.split_paren_token( token )
        opens = []
        while token.length > 1 && token.start_with?( OPEN_PAREN )
          opens << OPEN_PAREN
          token = token[ 1..-1 ]
        end
        closes = []
        while token.length > 1 && token.end_with?( CLOSE_PAREN )
          closes << CLOSE_PAREN
          token = token[ 0..-2 ]
        end
        return opens + [ token ] + closes
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Perform the operation.
      #
      def perform_op
        @op ||= Gloo::Core::Op.default_op
        l = evaluate_sym @left
        r = evaluate_sym @right
        @left = apply_op( @op, l, r )
        @right = nil
        @op = nil
      end

      #
      # Apply the operator. An operator that can't be used with the value
      # (eg. 'a' / 2), or a division by zero, is a runtime error, and the
      # result is no value. A missing value (nil) was already reported.
      #
      def apply_op( op, left, right )
        op.engine = @engine
        result = op.perform( left, right )
        if op.is_a?( Gloo::Expr::OpDiv ) && result.is_a?( Float ) &&
           ( result.nan? || result.infinite? )
          raise ZeroDivisionError
        end
        return result unless result.nil? && !left.nil?

        @engine.err "Operator '#{op.class::SYMBOL}' can't be used with '#{left}'."
        return nil
      rescue ZeroDivisionError
        @engine.err DIVIDE_BY_ZERO_ERR
        return nil
      end

      #
      # An operator without a value on one side (eg. 'show 1 +') is a
      # syntax error; the best guess is to leave the operator out.
      #
      def missing_value( op )
        @engine.syntax_err "Operator '#{op.class::SYMBOL}' is missing a value."
      end

      #
      # Evaluate the symbol and get a simple value.
      #
      def evaluate_sym( sym )
        return sym.value if sym.is_a? Gloo::Core::Literal
        return sym.value if sym.is_a? Gloo::Expr::Call
        return resolve_ref sym if sym.is_a? Gloo::Core::Pn
        # A group: worked out when it's reached, left to right.
        return sym.evaluate if sym.is_a? Gloo::Expr::Expression

        return sym
      end

      #
      # resolve an object reference and get the value.
      #
      def resolve_ref( ref )
        return ref.src if ref.named_color?

        name = ref.src
        ob = ref.resolve
        return ob.value if ob

        # The object is being used as a value, so a missing object is
        # a runtime error (the lookup itself doesn't report it).
        @engine.err Gloo::Core::NotFound.object( name )
        return nil
      end

      #
      # Identify each token in the list.
      #
      def identify_tokens
        tokens = Expression.split_parens( @tokens )
        i = 0
        while i < tokens.length
          token = tokens[ i ]
          if token == OPEN_PAREN
            close = matching_close( tokens, i )
            @symbols << group( tokens[ i + 1...close ] )
            i = close + 1
          else
            # A stray ')' was reported as a syntax error with the
            # command; the best guess is to leave it out.
            @symbols << identify_token( token ) unless token == CLOSE_PAREN
            i += 1
          end
        end
      end

      #
      # The index of the ')' that closes the '(' at open_index. An
      # unclosed group (reported as a syntax error with the command)
      # runs to the end, as the best guess.
      #
      def matching_close( tokens, open_index )
        depth = 0
        ( open_index...tokens.length ).each do |j|
          depth += 1 if tokens[ j ] == OPEN_PAREN
          depth -= 1 if tokens[ j ] == CLOSE_PAREN
          return j if depth.zero?
        end
        return tokens.length
      end

      #
      # A group in the expression: its own expression, worked out when
      # it is reached. An empty group is a syntax error, and no value.
      #
      def group( tokens )
        @engine.syntax_err EMPTY_GROUP_ERR if tokens.empty?

        return Expression.new( @engine, tokens )
      end

      #
      # Identify the tokens and create appropriate symbols.
      #
      def identify_token( token )
        return Gloo::Core::Op.create_op( token ) if Gloo::Core::Op.op?( token )

        return LBoolean.new( token ) if LBoolean.boolean?( token )
        return LInteger.new( token ) if LInteger.integer?( token )
        return LString.new( token ) if LString.string?( token )
        return LDecimal.new( token ) if LDecimal.decimal?( token )
        return Gloo::Expr::Call.new( @engine, token ) if Gloo::Expr::Call.call?( token )

        # last chance: an Object reference
        return Gloo::Core::Pn.new( @engine, token )
      end

    end
  end
end
