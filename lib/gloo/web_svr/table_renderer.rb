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
      def data_to_table( headers, data, styles )
        if data.length == 0
          return "<p>No data found.</p>"
        elsif data.length == 1
          return data_to_single_row_table( headers, data, styles )
        else
          return data_to_table_rows( headers, data, styles )
        end
      end

      # 
      # Show in single-row (form) format.
      # 
      def data_to_single_row_table( headers, data, styles )
        str = "<table class='#{styles[ TABLE ]}'> <tbody>"

        data.first.each_with_index do |cell,i|
          str += "<tr class='#{styles[ ROW ]}'>"
          str += "<th style='#{styles[ HEAD_CELL ]}'>#{headers[i]}</th>"
          str += "<td style='#{styles[ CELL ]}'>#{cell}</td>"
          str += "</tr>"
        end

        str += "</tbody></table>"
        return str
      end

      # 
      # Show in normal, multi-row format.
      # 
      def data_to_table_rows( headers, data, styles )
        str = "<table class='#{styles[ TABLE ]}'>"
        str << "<thead class='#{styles[ THEAD ]}'><tr>"

        headers.each do |header|
          str += "<th class='#{styles[ HEAD_CELL ]}'>#{header}</th>"
        end
        str << "</tr></thead><tbody>"

        data.each do |row|
          str += "<tr class='#{styles[ ROW ]}'>"
          row.each do |cell|
            str += "<td style='#{styles[ CELL ]}'>#{cell}</td>"
          end
          str += "</tr>"
        end
        str += "</tbody></table>"

        return str
      end

    end
    
  end
end
