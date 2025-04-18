# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2025 Eric Crane.  All rights reserved.
#
# Markdown extensions.
#

module Gloo
  module Objs
    class MarkdownExt

      PANEL = '[!PANEL'.freeze
      PANEL_PRIMARY = '[!PANEL PRIMARY]'.freeze
      PANEL_SECONDARY = '[!PANEL SECONDARY]'.freeze
      PANEL_SUCCESS = '[!PANEL SUCCESS]'.freeze
      PANEL_WARNING = '[!PANEL WARNING]'.freeze
      PANEL_DANGER = '[!PANEL DANGER]'.freeze


      # ---------------------------------------------------------------------
      #    Render all extensions.
      # ---------------------------------------------------------------------

      # 
      # Render gloo markdown extensions.
      # 
      def self.render_extensions data
        out_data = ""
        one_ext = ""
        in_ext = false
        data.lines.each_with_index do |line, index|
          if line.start_with?( '[!' )
            in_ext = true
            one_ext = line
          elsif in_ext && line.strip.blank?
            in_ext = false
            out_data << render_one_ext( one_ext )
            out_data << line
          elsif in_ext
            one_ext << line
          else
            out_data << line
          end
        end

        return out_data
      end

      # ---------------------------------------------------------------------
      #    Markdown Extensions
      # ---------------------------------------------------------------------

      # 
      # Render one markdown extension.
      # 
      def self.render_one_ext( data )
        if data.start_with?( PANEL )
          return render_panel( data )
        else
          # ERROR
          puts "ERROR: unknown markdown extension: #{data}"
          return ""
        end
      end

      # ---------------------------------------------------------------------
      #    Markdown Extensions
      # ---------------------------------------------------------------------

      # 
      # Render a panel.
      # 
      def self.render_panel( data )
        lns = data.lines
        i = lns[0].index( ']' )
        title = lns[0][i+1..-1].strip
        content = lns[1..-1].join("\n")
        alt = lns[0][8..i-1].downcase
        return "<div class='gloo-panel-container'>
          <div class='gloo-panel gloo-panel-#{alt}'>
            <h3 class='gloo-panel-title'>#{title}</h3>
            <p class='gloo-panel-content'>#{content}</p>
          </div>
        </div>"
      end

    end
  end
end
