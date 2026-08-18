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
          :description => 'A string value. For string interpolation, ' \
            'see the erb object type. Shares the same messages as the ' \
            'text object type; the two differ mainly by convention — ' \
            'string for a single word or line, text for longer, ' \
            'multi-line blocks.',
          :messages => StringMsgs.message_docs,
          :examples => <<~EXAMPLES.strip
            s [can] :
              msg [string] : Hello World!
              on_load [script] :
                show s.msg
                tell s.msg to up
                show s.msg
                tell s.msg to size
                show it
          EXAMPLES
        }
      end

    end
  end
end
