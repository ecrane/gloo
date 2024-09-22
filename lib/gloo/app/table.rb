# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# CLI input.
#
require 'colorize'
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
        puts str_value
        box = Terminal::Table.new( :headings => [], :rows => [ [ str_value ] ] )
        return box.to_s
      end

      #
      # Show the given table data.
      #
      def show( headers, data, title = nil )
        unless title.blank?
          table = Terminal::Table.new( 
            :title => title, :headings => headers, :rows => data )
        else
          table = Terminal::Table.new( :headings => headers, :rows => data )
        end
        puts table.to_s.colorize( color: :white, background: :black )
      end

      
      # ---------------------------------------------------------------------
      #    Private Functions
      # ---------------------------------------------------------------------

      private


    end
  end
end
