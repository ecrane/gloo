# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# The result of a SQL database query.
#
# require 'tty-table'

module Gloo
  module Objs
    class QueryResult

      DB = 'database'.freeze
      SQL = 'sql'.freeze
      RESULT = 'result'.freeze
      PARAMS = 'params'.freeze



      # ---------------------------------------------------------------------
      #    Set up the Result
      # ---------------------------------------------------------------------

      # 
      # Create the Result object
      def initialize( heads, data )
        @heads = heads
        @data = data
      end


      # ---------------------------------------------------------------------
      #    Helper Functions
      # ---------------------------------------------------------------------

      # 
      # Does the data contain a single row?
      # 
      def single_row_result?
        return @data.count == 1
      end

      # 
      # Does this query result have data to show?
      # 
      def has_data_to_show?
        return false unless @heads
        return false unless @data
        return false if @heads.count == 0
        return false if @data.count == 0

        return true
      end


      # ---------------------------------------------------------------------
      #    Show Results
      # ---------------------------------------------------------------------

      # 
      # Show the result of the query
      # 
      def show
        single_row_result? ? show_single_row : show_rows
      end

      # 
      # Show a single row in a vertical, form style view.
      # 
      def show_single_row
        arr = []
        row = @data[0]
        @heads.each_with_index do |h, i|
          arr << [ h, row[i] ]
        end
        table = TTY::Table.new( [ 'Field', 'Value' ], arr )
        renderer = TTY::Table::Renderer::Unicode.new( table, padding: [0,1] )
        puts renderer.render
      end

      # 
      # Show multiple rows in a table view.
      # 
      def show_rows
        table = TTY::Table.new( @heads, @data )
        renderer = TTY::Table::Renderer::Unicode.new( table, padding: [0,1] )
        puts renderer.render
      end

      # ---------------------------------------------------------------------
      #    Update results in object(s)
      # ---------------------------------------------------------------------

      #
      # Update the result container with the data from the query.
      #
      def update_result_container( in_can )
        @result_can = in_can
        single_row_result? ? update_single_row : update_rows
      end

      #
      # Update the result container with the data from the query.
      #
      def update_result_container_simple( in_can )
        @result_can = in_can
        single_row_result? ? update_single_row : update_rows_simple
      end

      # 
      # The result has a single row.
      # Map values from the result set to objects that are present.
      # 
      def update_single_row
        row = @data[0]
        @heads.each_with_index do |h, i|
          child = @result_can.find_child h          
          child.set_value row[i] if child
        end
      end

      # 
      # Put all rows in the result object.
      # 
      def update_rows
        @data.each_with_index do |row, i|
          can = @result_can.find_add_child( i.to_s, 'can' )
          row.each_with_index do |v, i|
            o = can.find_add_child( @heads[i], 'untyped' )
            o.set_value v
          end
        end
      end

      # 
      # Put all rows in the result object.
      # 
      def update_rows_simple
        @data.each do |row|
          row.each do |val|
            o = @result_can.find_add_child( val, 'untyped' )
            o.set_value val
          end
        end
      end


      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private



    end
  end
end
