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

      attr_reader :prompt

      #
      # Set up Platform.
      #
      def initialize
        # @prompt = TTY::Prompt.new
      end

      #
      # Show a message.
      #
      def show( msg, md=false, page=false )
        # if md
        #   # 2024.08.16 - TTY::Markdown.parse msg was not working.
        #   # Tried with redcarpet and it was not working either.
        #   # So just leaving it for now.  Not sure I even really need it.
        #   # TODO: Revisit and clean up.

        #   # msg = TTY::Markdown.parse msg
        #   # msg = Gloo::Objs::Markdown.md_2_manpage( msg )
        # end

        # if page
        #   # TODO: Replace tty-pager
        #   # pager = TTY::Pager::SystemPager.new command: 'less -R'
        #   # pager = TTY::Pager.new
        #   # pager.page( msg )
        # else
        puts msg
        # end
      end

      #
      # Prompt for the next command.
      #
      def prompt_cmd

        # TODO: Replace tty-prompt
        puts default_prompt
        return $stdin.gets.chomp

        # return @prompt.ask( default_prompt )
      end

      #
      # Clear the screen.
      #
      def clear_screen
        # TODO: Replace tty-cursor
        # @cursor ||= TTY::Cursor
        # print @cursor.clear_screen
        # print @cursor.move_to( 0, 0 )
        puts "\e[H\e[2J"
      end

      #
      # Edit some temporary text and return the edited text.
      #
      def edit initial_value
        # TODO: Replace tty-editor

        # tmp = File.join( $settings.tmp_path, DEFAULT_TMP_FILE )
        # File.open( tmp, 'w' ) { |file| file.write( initial_value ) }
        # TTY::Editor.open( tmp )
        # return File.read( tmp )
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
      #    Table helper
      # ---------------------------------------------------------------------

      #
      # Show the given table data.
      #
      def show_table( headers, data, title = nil )
        # TODO: Replace tty-table

        # pastel = ::Pastel.new
        # if headers
        #   table = TTY::Table.new headers, data
        # else
        #   table = TTY::Table.new rows: data
        # end
        # pad = [ 0, 1, 0, 1 ]
        # rendered = table.render( :ascii, indent: 2, padding: pad ) do |r|
        #   r.border.style = :blue
        #   r.filter = proc do |val, row_index, _col_index|
        #     # col_index % 2 == 1 ? pastel.red.on_green(val) : val
        #     if headers && row_index.zero?
        #       pastel.blue( val )
        #     else
        #       row_index.odd? ? pastel.white( val ) : pastel.yellow( val )
        #     end
        #   end
        # end
        # puts
        # puts "#{title.white}" if title
        # puts "#{rendered}\n\n"
      end

      # ---------------------------------------------------------------------
      #    Sceen helpers
      # ---------------------------------------------------------------------
      #
      # Get the number of vertical lines on screen.
      #
      def lines
        # TODO: Replace tty-screen
        # TTY::Screen.rows
        return 40
      end

      #
      # Get the number of horizontal columns on screen.
      #
      def cols
        # TODO: Replace tty-screen
        # TTY::Screen.cols
        return 80
      end

      # ---------------------------------------------------------------------
      #    Private Functions
      # ---------------------------------------------------------------------

      private

      #
      # Get the default prompt text.
      #
      def default_prompt
        dt = DateTime.now
        d = dt.strftime( '%Y.%m.%d' )
        t = dt.strftime( '%I:%M:%S' )
        return "#{'gloo'.blue} #{d.yellow} #{t.white} >"
      end

    end
  end
end
