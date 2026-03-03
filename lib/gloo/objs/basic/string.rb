# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A String.
#
require_relative 'string_msgs'

module Gloo
  module Objs
    class String < Gloo::Core::Obj

      include StringMsgs

      KEYWORD = 'string'.freeze
      KEYWORD_SHORT = 'str'.freeze
      MISSING_PARAM_MSG = 'Missing parameter!'.freeze

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
        return super + %w[up down size starts_with? ends_with? contains? 
          count_lines count_words count_chars
          format_for_html encode64 decode64 escape unescape
          gen_alphanumeric gen_uuid gen_hex gen_base64]
      end

    end
  end
end
