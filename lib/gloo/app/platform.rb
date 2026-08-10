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
      DEFAULT_LINES = 24
      DEFAULT_COLS = 80
      PAGER_CMD = 'less -R -F -X'.freeze

      attr_reader :prompt, :table
      attr_accessor :theme

      #
      # Set up Platform.
      #
      def initialize
        @prompt = Gloo::App::Prompt.new( self )
        @table = Gloo::App::Table.new( self )

        # Default theme, in case this platform is ever used
        # standalone, without an Engine to set the real one.
        @theme = Gloo::App::Theme.new
      end

      #
      # Show a message.
      #
      def show( msg )
        puts msg
      end

      #
      # Show a message in a pager (less), for long content.
      # Falls back to a plain puts when there is no real terminal
      # to page in (piped output, captured test output, etc) or
      # when less isn't available on the system.
      #
      def page( msg )
        return show( msg ) unless $stdout.tty?

        IO.popen( PAGER_CMD, 'w' ) { |less| less.puts msg }
      rescue Errno::ENOENT
        show( msg )
      rescue Errno::EPIPE
        # The user quit the pager early. Nothing more to do.
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
      def get_file_mech( engine )
        return Gloo::Persist::DiscMech.new( engine )
      end


      # ---------------------------------------------------------------------
      #    Color helper
      # ---------------------------------------------------------------------

      # 
      # Get colorized string.
      # 
      def get_colorized_string( str, color )
        colorized = ColorizedString[ str.to_s ].colorize( color )
        return colorized.to_s
      end


      # ---------------------------------------------------------------------
      #    Sceen helpers
      # ---------------------------------------------------------------------
      #
      # Get the number of vertical lines on screen.
      # Falls back to a default when stdout has no real screen behind it
      # (piped/captured output, no controlling TTY, etc).
      #
      def lines
        rows, _columns = $stdout.winsize
        return rows
      rescue StandardError
        return DEFAULT_LINES
      end

      #
      # Get the number of horizontal columns on screen.
      # Falls back to a default when stdout has no real screen behind it
      # (piped/captured output, no controlling TTY, etc).
      #
      def cols
        _rows, columns = $stdout.winsize
        return columns
      rescue StandardError
        return DEFAULT_COLS
      end

      # ---------------------------------------------------------------------
      #    Private Functions
      # ---------------------------------------------------------------------

      private

    end
  end
end
