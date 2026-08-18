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
            'and END to mark the text range. Shares the same messages ' \
            'as the string object type; the two differ mainly by ' \
            'convention — text for longer, multi-line blocks, string ' \
            'for a single word or line.',
          :messages => StringMsgs.message_docs,
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
