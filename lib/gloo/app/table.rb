# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# CLI input.
#
require 'terminal-table'

module Gloo
  module App
    class Table

      #
      # Set up Table Helper.
      #
      def initialize platform
        @platform = platform
      end

      # 
      # Put a box around the given string.
      def box( str_value )
        # puts str_value
        box = Terminal::Table.new( :headings => [], :rows => [ [ str_value ] ] )
        return box.to_s
      end

      #
      # Show the given table data.
      #
      # Deliberately left uncolored: box-drawing borders and text read
      # fine against the terminal's own default colors, and forcing a
      # fixed foreground/background (as this used to do) fought
      # whatever theme the terminal was actually running.
      #
      def show( headers, data, title = nil )
        unless title.blank?
          table = Terminal::Table.new(
            :title => title, :headings => headers, :rows => data )
        else
          table = Terminal::Table.new( :headings => headers, :rows => data )
        end
        puts table.to_s
      end

      
      # ---------------------------------------------------------------------
      #    Private Functions
      # ---------------------------------------------------------------------

      private


    end
  end
end
