# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# A helper class used to render HTML tables.
# 

module Gloo
  module WebSvr
    class TableRenderer

      TABLE = 'table'.freeze
      THEAD = 'thead'.freeze
      HEAD_CELL = 'head_cell'.freeze
      ROW = 'row'.freeze
      CELL = 'cell'.freeze

      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine )
        @engine = engine
        @log = @engine.log
      end


      # ---------------------------------------------------------------------
      #    Container Renderer
      # ---------------------------------------------------------------------

      # 
      # Render the query result set to an HTML table.
      # 
      # params = { 
      #   head: head, 
      #   cols: result[0],
      #   rows: rows,
      #   styles: self.styles,
      #   cell_renderers: self.cell_renderers
      # }
      # 
      def data_to_table params
        data = params[ :rows ]
        
        if data.nil? || ( data.length == 0 )
          return "<p>No data found.</p>"
        elsif data.length == 1
          return data_to_single_row_table( params )
        else
          return data_to_table_rows( params )
        end
      end

      # 
      # Show in single-row (form) format.
      # 
      def data_to_single_row_table( params )
        styles = params[ :styles ]
        str = "<table class='#{styles[ TABLE ]}'> <tbody>"
        row = params[ :rows ].first
        
        params[ :columns ].each do |head|
          next unless head[ :visible ]
          cell = row[ head[ :data_index ] ]

          if head[ :cell_renderer ]
            cell_value = render_cell( row, head, params[ :columns ] )
          else
            cell_value = cell
          end

          str += "<tr class='#{styles[ ROW ]}'>"
          str += "<th style='#{styles[ HEAD_CELL ]}'>#{head[ :title ]}</th>"
          str += "<td style='#{styles[ CELL ]}'>#{cell_value}</td>"
          str += "</tr>"
        end

        str += "</tbody></table>"
        return str
      end

      # 
      # Show in normal, multi-row format.
      # 
      def data_to_table_rows( params )
        styles = params[ :styles ]
        # headers = params[ :head ]

        str = "<table class='#{styles[ TABLE ]}'>"
        str << "<thead class='#{styles[ THEAD ]}'><tr>"

        params[ :columns ].each do |head|
          next unless head[ :visible ]
          str += "<th class='#{styles[ HEAD_CELL ]}'>#{head[ :title ]}</th>"
        end
        str << "</tr></thead><tbody>"

        params[ :rows ].each do |row|
          str += "<tr class='#{styles[ ROW ]}'>"

          # row.each_with_index do |cell, i|
          params[ :columns ].each do |head|
            next unless head[ :visible ]

            cell = row[ head[ :data_index ] ]
            this_col_name = head[ :name ]

            if head[ :cell_renderer ]
              cell_value = render_cell( row, head, params[ :columns ] )
            else
              cell_value = cell
            end
            str += "<td style='#{styles[ CELL ]}'>#{cell_value}</td>"
          end
          str += "</tr>"
        end
        str += "</tbody></table>"

        return str
      end

      # 
      # Render a cell using the cell renderer and the given
      # context data (the row's values).
      # 
      def render_cell row, col, cols
        params = {}

        cols.each_with_index do |c, i|
          params[ c[ :name ] ] = row[ c[ :data_index ] ]
        end
      
        content = col[ :cell_renderer ]
        content = @engine.running_app.obj.embedded_renderer.render content, params

        # renderer = ERB.new( col[ :cell_renderer ] )
        # content = renderer.result_with_hash( params )
      
        return content
      end
    end
    
  end
end
