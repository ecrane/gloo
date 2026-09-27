# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An Expression that can be evaluated.
#

module Gloo
  module Expr
    class Expression

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

        return @left.value if @left.is_a? Gloo::Core::Literal
        return @left.value if @left.is_a? Gloo::Expr::Call
        return resolve_ref @left if @left.is_a? Gloo::Core::Pn

        return @left
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
        @left = @op.perform l, r
        @right = nil
        @op = nil
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
        @tokens.each do |o|
          @symbols << identify_token( o )
        end
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
