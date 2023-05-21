# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Markdown data.
#

module Gloo
  module Objs
    class Markdown < Gloo::Core::Obj

      KEYWORD = 'markdown'.freeze
      KEYWORD_SHORT = 'md'.freeze

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
        return super + %w[show page]
      end

      #
      # Show the markdown data in the terminal.
      #
      def msg_show
        @engine.platform.show( self.value, true, false )
      end

      #
      # Show the markdown data in the terminal, paginated.
      #
      def msg_page
        return unless self.value

        @engine.platform.show( md, true, true )
      end

    end
  end
end
