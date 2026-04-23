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
        return super + %w[up down size starts_with? ends_with? substring? sub gsub
          count_lines count_words count_chars trim
          format_for_html encode64 decode64 escape unescape
          gen_alphanumeric gen_uuid gen_hex gen_base64]
      end

    end
  end
end
