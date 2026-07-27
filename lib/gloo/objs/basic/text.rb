# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A [multiline] block of text.
#
require_relative 'string_msgs'

module Gloo
  module Objs
    class Text < Gloo::Core::Obj

      include StringMsgs

      KEYWORD = 'text'.freeze
      KEYWORD_SHORT = 'txt'.freeze

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

      #
      # Does this object support multi-line values?
      # Initially only true for scripts.
      #
      def multiline_value?
        return false
      end

      #
      # Get the number of lines of text.
      #
      def line_count
        return value.split( "\n" ).count
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + StringMsgs.messages
      end

      # ---------------------------------------------------------------------
      #    Object Documentation
      # ---------------------------------------------------------------------

      #
      # Get the object's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'A longer, multi-line text string. Use BEGIN ' \
            'and END to mark the text range.',
          :messages => [
            'Same messages as the string object type:',
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
            'sub ({from}, {to}) — Substitute the first occurrence of {from} with {to}. Both parameters are required. This message changes the value of the string. It will have the result.',
            'gsub ({from}, {to}) — Substitute all occurrences of {from} with {to}. Both parameters are required. This message changes the value of the string. It will have the result.',
            'page — Show the value in a pager (less), for viewing long content a screen at a time.'
          ],
          :examples => <<~EXAMPLES.strip
            t [container] :
              msg [txt] : BEGIN
                I will now write a poem
                of two lines or less
                END
              on_load [script] :
                show t.msg
          EXAMPLES
        }
      end

    end
  end
end
