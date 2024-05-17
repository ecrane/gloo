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
      # Handle a missing method by looking for a helper function.
      # If there is one, then call it and return the result.
      # If not, log an error and return nil.
      # 
      def can_to_table( headers, data, styles )
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
