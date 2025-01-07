# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# Handle input and output for the CLI platform.
#
require 'active_support'
require 'colorize'
require 'colorized_string'

module Gloo
  module App
    class Platform

      DEFAULT_TMP_FILE = 'tmp.txt'.freeze
      RETURN = "\n".freeze

      attr_reader :prompt, :table

      #
      # Set up Platform.
      #
      def initialize
        @prompt = Gloo::App::Prompt.new( self )
        @table = Gloo::App::Table.new( self )
      end

      #
      # Show a message.
      #
      def show( msg )
        puts msg
      end

      #
      # Clear the screen.
      #
      def clear_screen
        puts "\e[H\e[2J"
      end

      # 
      # Get the file mechanism for this platform.
      # 
      def getFileMech( engine )
        return Gloo::Persist::DiscMech.new( engine )
      end


      # ---------------------------------------------------------------------
      #    Color helper
      # ---------------------------------------------------------------------

      # 
      # Get colorized string.
      # 
      def getColorizedString( str, color )
        colorized = ColorizedString[ str.to_s ].colorize( color )
        return colorized.to_s
      end


      # ---------------------------------------------------------------------
      #    Sceen helpers
      # ---------------------------------------------------------------------
      #
      # Get the number of vertical lines on screen.
      #
      def lines
        rows, columns = $stdout.winsize
        return rows
      end

      #
      # Get the number of horizontal columns on screen.
      #
      def cols
        rows, columns = $stdout.winsize
        return columns
      end

      # ---------------------------------------------------------------------
      #    Private Functions
      # ---------------------------------------------------------------------

      private

    end
  end
end
