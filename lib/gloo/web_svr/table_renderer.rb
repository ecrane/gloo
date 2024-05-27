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
        
        if data.length == 0
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
        headers = params[ :head ]

        str = "<table class='#{styles[ TABLE ]}'> <tbody>"

        row = params[ :rows ].first
        row.each_with_index do |cell,i|
          this_col_name = params[ :cols ][ i ]
          cell_r = params[ :cell_renderers ][ this_col_name ]
          if cell_r
            cell_value = render_cell( cell, cell_r, row, params[ :cols ])
          else
            cell_value = cell
          end

          str += "<tr class='#{styles[ ROW ]}'>"
          str += "<th style='#{styles[ HEAD_CELL ]}'>#{headers[i]}</th>"
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
        headers = params[ :head ]

        str = "<table class='#{styles[ TABLE ]}'>"
        str << "<thead class='#{styles[ THEAD ]}'><tr>"

        headers.each do |header|
          str += "<th class='#{styles[ HEAD_CELL ]}'>#{header}</th>"
        end
        str << "</tr></thead><tbody>"

        params[ :rows ].each do |row|
          str += "<tr class='#{styles[ ROW ]}'>"
          row.each_with_index do |cell, i|
            this_col_name = params[ :cols ][ i ]
            cell_r = params[ :cell_renderers ][ this_col_name ]
            if cell_r
              cell_value = render_cell( cell, cell_r, row, params[ :cols ])
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
      def render_cell cell, cell_renderer, context_data, cols
        params = {}

        context_data.each_with_index do |cell, i|
          params[ cols[i] ] = cell
        end
      
        renderer = ERB.new( cell_renderer )
        content = renderer.result_with_hash( params )
      
        return content
      end
    end
    
  end
end
