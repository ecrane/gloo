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
      # Get the list of message names this mixin implements, derived
      # from its own msg_* methods so String/Text don't have to
      # hand-duplicate the list (and can't drift out of sync with it).
      #
      def self.messages
        return instance_methods( false )
          .select { |m| m.to_s.start_with?( 'msg_' ) }
          .map { |m| m.to_s.sub( /\Amsg_/, '' ) }
      end

      #
      # Documentation for each message this mixin implements, for use
      # in String and Text's doc_data (see help_shell). Kept here as
      # the single source, since String and Text share the exact
      # same message set and would otherwise have to keep two
      # hand-written copies of this list in sync.
      #
      def self.message_docs
        return [
          'up — Convert the string to uppercase. This message changes the value of the string.',
          'down — Convert the string to lowercase. This message changes the value of the string.',
          'size — Get the size of the string. It will have the string size.',
          'count_chars — Count the number of characters in the string. It will have the character count.',
          'count_words — Count the number of words in the string. It will have the word count.',
          'count_lines — Count the number of lines in the string. It will have the line count.',
          'starts_with? ({str}) — Check if the string starts with the given string. A parameter is required: the string to look for at the beginning of this string. It will have a boolean.',
          'ends_with? ({str}) — Check if the string ends with the given string. A parameter is required: the string to look for at the end of this string. It will have a boolean.',
          'substring? ({str}) — Check if the string includes the given sub-string. A parameter is required: the string to look for in this string. It will have a boolean.',
          'format_for_html — Format this string for HTML output. Tabs, spaces and returns are converted to HTML elements. The value of the string is changed.',
          'encode64 — Base64 encode the string. This message changes the value of the string. It will have the encoded string.',
          'decode64 — Decode the string from Base64. This message changes the value of the string. It will have the decoded string.',
          'escape — Escape the string to make it URL safe. This message changes the value of the string. It will have the escaped string.',
          'unescape — Unescape the string (from URL safe format). This message changes the value of the string. It will have the unescaped string.',
          'gen_uuid — Set the value of the string to a newly generated, random UUID. This message changes the value of the string.',
          'gen_alphanumeric ({len}) — Set the value of the string to a newly generated, random alphanumeric string. The {len} parameter is optional; the length is 10 if not specified. This message changes the value of the string.',
          'gen_hex ({len}) — Set the value of the string to a newly generated, random hex string. The {len} parameter is optional; the length is 10 if not specified. This message changes the value of the string.',
          'gen_base64 ({len}) — Set the value of the string to a newly generated, random base64 string. The {len} parameter is optional; the length is 12 if not specified. This message changes the value of the string.',
          'trim — Strip whitespace from the beginning and end of the string. This message changes the value of the string. It will have the trimmed string.',
          'sub ({from} {to}) — Substitute the first occurrence of {from} with {to}. Both parameters are required. This message changes the value of the string. It will have the result.',
          'gsub ({from} {to}) — Substitute all occurrences of {from} with {to}. Both parameters are required. This message changes the value of the string. It will have the result.',
          'split ({from} {to}) — Get the substring from index {from} up to (not including) index {to}. Indexes are 0-based; out-of-range indexes are clamped to the start or end of the string. Both parameters are required. Does not change the value of the string. It will have the substring.',
          'splitl ({index}) — Get the substring to the left of index {index} (same as split (0, {index})). A parameter is required. Does not change the value of the string. It will have the substring.',
          'splitr ({index}) — Get the substring from index {index} to the end of the string (same as split ({index}, size)). A parameter is required. Does not change the value of the string. It will have the substring.',
          'split_list ({delim} {dst.path}) — Split the string by {delim} and put the parts into children of the container at {dst.path} (or an alias that points to one), one part per child, in order. Existing children are matched by position and have their values set; extra parts get new (untyped) children, numbered from 1; extra existing children are left alone. Both parameters are required. Does not change the value of the string. It will have the number of parts.',
          'page — Show the value in a pager (less), for viewing long content a screen at a time.'
        ]
      end


      #
      # Strip whitespace from the beginning and end of the string.
      #
      def msg_trim
        return '' unless value
        
        result = value.strip
        @engine.heap.it.set_to result
        set_value(result)
        return result
      end

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
        return '' unless value
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
        return '' unless value

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
      # Get the substring from index {from} up to (not including) index {to}.
      # Indexes are 0-based. Out-of-range indexes are clamped to the
      # beginning or end of the string. Does not change the string's value.
      #
      def msg_split
        return '' unless value

        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, [ @params.tokens.first ] )
          from = expr.evaluate.to_i
          expr = Gloo::Expr::Expression.new( @engine, [ @params.tokens.last ] )
          to = expr.evaluate.to_i

          result = clamped_substring( from, to )
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
      # Get the substring to the left of (not including) index {index}.
      # Same as split( 0, index ). Does not change the string's value.
      #
      def msg_splitl
        return '' unless value

        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          index = expr.evaluate.to_i

          result = clamped_substring( 0, index )
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
      # Get the substring from index {index} to the end of the string.
      # Same as split( index, size ). Does not change the string's value.
      #
      def msg_splitr
        return '' unless value

        if @params&.token_count&.positive?
          expr = Gloo::Expr::Expression.new( @engine, @params.tokens )
          index = expr.evaluate.to_i

          result = clamped_substring( index, value.length )
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
      # Split the string by the given delimiter and put the parts into
      # children of the target container, one part per child, in order.
      # The target is a path to a container, or to an alias that points
      # to one. Existing children are matched by position (not name) and
      # have their values set; if there are more parts than children,
      # new (untyped) children are created for the extras, numbered
      # from 1. Existing children beyond the part count are left alone.
      # The string's own value is unchanged; the number of parts is put
      # into 'it'.
      #
      def msg_split_list
        return unless value

        if @params&.token_count.to_i < 2
          @engine.log.error MISSING_PARAM_MSG
          @engine.heap.it.set_to false
          return false
        end

        expr = Gloo::Expr::Expression.new( @engine, [ @params.tokens.first ] )
        delim = expr.evaluate

        target = split_list_target( @params.tokens.last )
        return false unless target

        parts = value.split( delim )
        existing = target.children
        parts.each_with_index do |part, index|
          child = existing[ index ]
          child ||= target.find_add_child( ( index + 1 ).to_s, 'untyped' )
          child.set_value part
        end

        count = parts.count
        @engine.heap.it.set_to count
        return count
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

      #
      # Show the value in a pager, for long content.
      #
      def msg_page
        return unless value

        @engine.platform.page( value )
      end

      private

      #
      # Resolve the target container path for split_list. The path may
      # point directly at a container, or at an alias that points to
      # one. Returns nil (and logs an error, setting 'it' to false)
      # if the path doesn't exist or doesn't resolve to a container.
      #
      def split_list_target( token )
        pn = Gloo::Core::Pn.new( @engine, token )
        unless pn&.exists?
          @engine.log.error 'Target container path does not exist!'
          @engine.heap.it.set_to false
          return nil
        end

        target = pn.resolve
        target = Gloo::Objs::Alias.resolve_alias( @engine, target )
        unless target&.is_container?
          @engine.log.error 'Target for split_list must be a container!'
          @engine.heap.it.set_to false
          return nil
        end

        return target
      end

      #
      # Get the substring from index {from} up to (not including) index {to}.
      # Out-of-range indexes are clamped to the string's own bounds (0 and
      # its length), rather than raising an error. A degenerate range
      # (from at or past to) returns an empty string.
      #
      def clamped_substring( from, to )
        len = value.length
        from = 0 if from.negative?
        from = len if from > len
        to = 0 if to.negative?
        to = len if to > len
        return '' if from >= to

        return value[ from...to ]
      end

    end
  end
end

