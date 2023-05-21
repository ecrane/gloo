# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A [multiline] block of text.
#

module Gloo
  module Objs
    class Text < Gloo::Core::Obj

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
        return super + %w[edit page]
      end

      #
      # Show the contents of the file, paginated.
      #
      def msg_page
        return unless value

        @engine.platform.show( value, false, true )
      end

      #
      # Edit the text in the default editor.
      #
      def msg_edit
        self.value = @engine.platform.edit( self.value )
      end

    end
  end
end
