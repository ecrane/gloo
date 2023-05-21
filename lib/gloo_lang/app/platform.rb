# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# Handle input and output for the current platform.
#
# This is an abstract base class and minimal implementation
# is only to facilitate testing.
#

module GlooLang
  module App
    class Platform

      #
      # Set up Platform.
      #
      def initialize
      end

      #
      # Show a message.
      # Abstract--implment in subclass.
      #
      def show( msg, md=false, page=false )
        puts msg
      end

      #
      # Prompt for the next command.
      # Abstract--implment in subclass.
      #
      def prompt_cmd
        return ''
      end

      #
      # Clear the screen.
      # Abstract--implment in subclass.
      #
      def clear_screen
      end

      #
      # Edit some temporary text and return the edited text.
      # Abstract--implment in subclass.
      #
      def edit initial_value
        return initial_value
      end

      #
      # Show the given table data.
      # Abstract--implment in subclass.
      #
      def show_table( headers, data, title = nil )
      end

      #
      # Get the number of vertical lines on screen.
      # Abstract--implment in subclass.
      #
      def lines
        return 40
      end

      #
      # Get the number of horizontal columns on screen.
      # Abstract--implment in subclass.
      #
      def cols
        return 80
      end

      # 
      # Get the file mechanism for this platform.
      # 
      def getFileMech( engine )
        return GlooLang::Persist::DiscMech.new( engine )
      end

      # 
      # Get colorized string.
      # 
      def getColorizedString( string, color )
        return str
      end

    end
  end
end
