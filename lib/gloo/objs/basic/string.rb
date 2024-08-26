# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A String.
#

module Gloo
  module Objs
    class String < Gloo::Core::Obj

      KEYWORD = 'string'.freeze
      KEYWORD_SHORT = 'str'.freeze

      #
      # The name of the object type.
      #
      def self.typename
        return KEYWORD
      end

      #
      # The short name of the object type.
      #
      def self.short_typename
        return KEYWORD_SHORT
      end

      #
      # Set the value with any necessary type conversions.
      #
      def set_value( new_value )
        self.value = new_value.to_s
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[up down size gen_alphanumeric gen_uuid gen_hex gen_base64]
      end

      #
      # Get the size of the string.
      #
      def msg_size
        s = value.size
        @engine.heap.it.set_to s
        return s
      end

      #
      # Generate a new UUID in the string.
      #
      def msg_gen_uuid
        s = StringGenerator.uuid
        set_value s
        @engine.heap.it.set_to s
        return s
      end

      #
      # Generate a random alphanumeric string.
      # By default the length is 10 characters.
      # Set the length with an optional parameter.
      #
      def msg_gen_alphanumeric
        len = 10
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
          len = data.to_i
        end

        s = StringGenerator.alphanumeric( len )
        set_value s
        @engine.heap.it.set_to s
        return s
      end

      #
      # Generate a random hex string.
      # By default the length is 10 hex characters.
      # Set the length with an optional parameter.
      #
      def msg_gen_hex
        len = 10
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
          len = data.to_i
        end

        s = StringGenerator.hex( len )
        set_value s
        @engine.heap.it.set_to s
        return s
      end

      #
      # Generate a random base64 string.
      # By default the length is 12 characters.
      # Set the length with an optional parameter.
      #
      def msg_gen_base64
        len = 12
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate
          len = data.to_i
        end

        s = StringGenerator.base64( len )
        set_value s
        @engine.heap.it.set_to s
        return s
      end

      #
      # Convert string to upper case
      #
      def msg_up
        s = value.upcase
        set_value s
        @engine.heap.it.set_to s
        return s
      end

      #
      # Convert string to lower case
      #
      def msg_down
        s = value.downcase
        set_value s
        @engine.heap.it.set_to s
        return s
      end

    end
  end
end
