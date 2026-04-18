# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Some message implementations shared by String and Text objs.
#
require 'base64'
require 'uri'

module Gloo
  module Objs
    module StringMsgs

      # 
      # Does the string start with the given string?
      # 
      def msg_starts_with?
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate

          result = self.value.start_with?( data )
          @engine.heap.it.set_to result
          return result
        else
          # Error
          @engine.log.error MISSING_PARAM_MSG
          @engine.heap.it.set_to false
          return false
        end
      end

      # 
      # Does the string end with the given string?
      # 
      def msg_ends_with?
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate

          result = value.end_with?( data )
          @engine.heap.it.set_to result
          return result
        else
          # Error
          @engine.log.error MISSING_PARAM_MSG
          @engine.heap.it.set_to false
          return false
        end
      end

      # 
      # Substitute the given string with another string.
      #
      def msg_sub
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, [ @params.tokens.first ] )
          from = expr.evaluate
          expr = Gloo::Expr::Expression.new( @engine, [ @params.tokens.last ] )
          to = expr.evaluate

          result = value.sub(from, to)
          @engine.heap.it.set_to result
          set_value(result)
          return result
        else
          # Error
          @engine.log.error MISSING_PARAM_MSG
          @engine.heap.it.set_to false
          return false
        end
      end

      # 
      # Substitute the given string with another string.
      # Find all occurrences and replace them.
      #
      def msg_gsub
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, [ @params.tokens.first ] )
          from = expr.evaluate
          expr = Gloo::Expr::Expression.new( @engine, [ @params.tokens.last ] )
          to = expr.evaluate

          result = value.gsub(from, to)
          @engine.heap.it.set_to result
          set_value(result)
          return result
        else
          # Error
          @engine.log.error MISSING_PARAM_MSG
          @engine.heap.it.set_to false
          return false
        end
      end

      # 
      # Does the string contain the given string?
      #
      # This was formerly an overload of obj.contains?
      # Contains? for the Obj checks for the presense of children.
      #
      def msg_substring?
        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          data = expr.evaluate

          result = value.include?( data )
          @engine.heap.it.set_to result
          return result
        else
          @engine.heap.it.set_to false
          return false
        end
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
      # Get the number of characters in the string.
      #
      def msg_count_chars
        s = value.chars.count
        @engine.heap.it.set_to s
        return s
      end

      #
      # Get the number of words in the string.
      #
      def msg_count_words
        s = value.split( " " ).count
        @engine.heap.it.set_to s
        return s
      end

      #
      # Get the number of lines in the string.
      #
      def msg_count_lines
        s = value.split( "\n" ).count
        @engine.heap.it.set_to s
        return s
      end

      # 
      # Convert whitespace to HTML friendly spaces.
      # 
      def msg_format_for_html
        text = self.value
        out = ""
        return out unless text

        # indentation
        text.each_line do |line|
          i = 0
          while line[i] == ' '
            i += 1
            out << "&nbsp;"
          end
    
          i = 0
          while line[i] == "\t"
            i += 1
            out << "&nbsp;&nbsp;&nbsp;&nbsp;"
          end
          out << line
        end
    
        self.value = out.gsub( "\n", "<br/>" )
      end

      # 
      # Escape the string.
      # Make it URL safe.
      # The value of the string is changed.
      # 
      def msg_escape
        s = URI::DEFAULT_PARSER.escape( value )
        set_value s
        @engine.heap.it.set_to s
        return s
      end

      # 
      # Unescape the string.
      # The value of the string is changed.
      # 
      def msg_unescape
        s = URI::DEFAULT_PARSER.unescape( value )
        set_value s
        @engine.heap.it.set_to s
        return s
      end

      # 
      # Encode the string as base64.
      # Changes the value of the string.
      # 
      def msg_encode64
        s = Base64.encode64( value )
        set_value s
        @engine.heap.it.set_to s
        return s
      end

      # 
      # Decode the string from base64.
      # Changes the value of the string.
      # 
      def msg_decode64
        s = Base64.decode64( value )
        set_value s
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

