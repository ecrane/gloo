# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A [multiline] block of text.
#
require 'tty-editor'
require 'tty-pager'

module Gloo
  module Objs
    class Text < Gloo::Core::Obj

      KEYWORD = 'text'.freeze
      KEYWORD_SHORT = 'txt'.freeze
      DEFAULT_TMP_FILE = 'tmp.txt'.freeze

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

        # pager = TTY::Pager::SystemPager.new command: 'less -R'
        pager = TTY::Pager.new
        pager.page( value )
      end

      #
      # Edit the text in the default editor.
      #
      def msg_edit
        tmp = File.join( $settings.tmp_path, DEFAULT_TMP_FILE )
        File.open( tmp, 'w' ) { |file| file.write( self.value ) }
        TTY::Editor.open( tmp )
        set_value File.read( tmp )
      end

    end
  end
end
