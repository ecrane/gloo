# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# The result of a SQL database query.
#

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
        row = @data[0]
        @heads.each_with_index do |h, i|
          puts "#{h}: \t #{row[i]}"
        end
      end

      # 
      # Show multiple rows in a table view.
      # 
      def show_rows
        puts @heads.map { |o| o }.join( " \t " ).white
        
        @data.each do |row|
          # Show the row data
          puts row.map { |v| v }.join( " \t " )
        end
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
      
      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private



    end
  end
end
