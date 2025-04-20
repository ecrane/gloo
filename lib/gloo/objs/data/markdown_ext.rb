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

      QUOTE = '[!QUOTE]'.freeze
      INFO = '[!INFO]'.freeze
      NOTE = '[!NOTE]'.freeze
      CHECK = '[!CHECK]'.freeze


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
        elsif data.start_with?( QUOTE )
          return render_quote( data )
        elsif data.start_with?( INFO )
          return render_info( data )
        elsif data.start_with?( NOTE )
          return render_note( data )
        elsif data.start_with?( CHECK )
          return render_check( data )
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
      # Render an info icon.
      # 
      def self.render_info( data )
        return render_panel( data, 'primary', info_svg + " &nbsp; " )
      end

      # 
      # Render a note icon.
      # 
      def self.render_note( data )
        return render_panel( data, 'secondary', note_svg + " &nbsp; " )
      end

      # 
      # Render a check icon.
      # 
      def self.render_check( data )
        return render_panel( data, 'success', check_svg + " &nbsp; " )
      end

      # 
      # Render a panel.
      # 
      def self.render_panel( data, style_def = nil, title_prefix = '' )
        lns = data.lines
        i = lns[0].index( ']' )
        title = title_prefix + lns[0][i+1..-1].strip
        content = lns[1..-1].join("\n")
        alt = style_def || lns[0][8..i-1].downcase
        
        html = <<~HTML
          <div class="gloo-panel-container">
            <div class="gloo-panel gloo-panel-#{alt}">
              <h3 class="gloo-panel-title">#{title}</h3>
              <p class="gloo-panel-content">#{content}</p>
            </div>
          </div>
        HTML

        return html
      end

      # 
      # Render a quote.
      # 
      def self.render_quote( data )
        lns = data.lines
        i = lns[0].index( ']' )
        title = lns[0][i+1..-1].strip
        content = lns[1..-1].join("\n")
        alt = lns[0][8..i-1].downcase
        
        html = <<~HTML
          <div class="gloo-quote-container">
            <div class="gloo-quote gloo-quote-#{alt}">
              <h3 class="gloo-quote-title">#{quote_svg} &nbsp; #{title}</h3>
              <p class="gloo-quote-content">#{content}</p>
            </div>
          </div>
        HTML

        return html
      end

      # 
      # Get the Check svg.
      # 
      def self.check_svg
        return <<~SVG
          <svg width="30px" height="30px" 
            viewBox="0 0 30 30" fill="none" 
            xmlns="http://www.w3.org/2000/svg">
            <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
            <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
            <g id="SVGRepo_iconCarrier"> 
              <path d="M18 20.75H6C5.27065 20.75 4.57118 20.4603 4.05546 19.9445C3.53973 19.4288 3.25 18.7293 3.25 18V6C3.25 5.27065 3.53973 4.57118 4.05546 4.05546C4.57118 3.53973 5.27065 3.25 6 3.25H14.86C15.0589 3.25 15.2497 3.32902 15.3903 3.46967C15.531 3.61032 15.61 3.80109 15.61 4C15.61 4.19891 15.531 4.38968 15.3903 4.53033C15.2497 4.67098 15.0589 4.75 14.86 4.75H6C5.66848 4.75 5.35054 4.8817 5.11612 5.11612C4.8817 5.35054 4.75 5.66848 4.75 6V18C4.75 18.3315 4.8817 18.6495 5.11612 18.8839C5.35054 19.1183 5.66848 19.25 6 19.25H18C18.3315 19.25 18.6495 19.1183 18.8839 18.8839C19.1183 18.6495 19.25 18.3315 19.25 18V10.29C19.25 10.0911 19.329 9.90032 19.4697 9.75967C19.6103 9.61902 19.8011 9.54 20 9.54C20.1989 9.54 20.3897 9.61902 20.5303 9.75967C20.671 9.90032 20.75 10.0911 20.75 10.29V18C20.75 18.7293 20.4603 19.4288 19.9445 19.9445C19.4288 20.4603 18.7293 20.75 18 20.75Z" fill="#2ec946"></path> 
              <path d="M10.5 15.25C10.3071 15.2352 10.1276 15.1455 10 15L7.00001 12C6.93317 11.86 6.91136 11.7028 6.93759 11.5499C6.96382 11.3971 7.03679 11.2561 7.14646 11.1464C7.25613 11.0368 7.3971 10.9638 7.54996 10.9376C7.70282 10.9113 7.86006 10.9331 8.00001 11L10.47 13.47L19 4.99998C19.14 4.93314 19.2972 4.91133 19.4501 4.93756C19.6029 4.96379 19.7439 5.03676 19.8536 5.14643C19.9632 5.2561 20.0362 5.39707 20.0624 5.54993C20.0887 5.70279 20.0669 5.86003 20 5.99998L11 15C10.8724 15.1455 10.693 15.2352 10.5 15.25Z" fill="#2ec946"></path> 
            </g>
          </svg>
        SVG
      end

      # 
      # Get the note svg.
      # 
      def self.note_svg
        return <<~SVG
          <svg width="24px" height="24px" 
            viewBox="0 0 24 24" 
            fill="none" 
            xmlns="http://www.w3.org/2000/svg" 
            stroke="#a1a1a1">
            <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
            <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
            <g id="SVGRepo_iconCarrier"> 
              <path d="M19.8201 14H15.6001C15.04 14 14.76 14 14.5461 14.109C14.3579 14.2049 14.2049 14.3578 14.1091 14.546C14.0001 14.7599 14.0001 15.0399 14.0001 15.6V19.82M20 12.7269V7.2C20 6.0799 20 5.51984 19.782 5.09202C19.5903 4.71569 19.2843 4.40973 18.908 4.21799C18.4802 4 17.9201 4 16.8 4H7.2C6.0799 4 5.51984 4 5.09202 4.21799C4.71569 4.40973 4.40973 4.71569 4.21799 5.09202C4 5.51984 4 6.0799 4 7.2V16.8C4 17.9201 4 18.4802 4.21799 18.908C4.40973 19.2843 4.71569 19.5903 5.09202 19.782C5.51984 20 6.0799 20 7.2 20H12.9496C13.4578 20 13.7118 20 13.9498 19.9407C14.1608 19.8882 14.3618 19.8016 14.5449 19.6844C14.7515 19.5522 14.926 19.3675 15.2751 18.9983L19.1254 14.9252C19.4486 14.5833 19.6101 14.4124 19.7255 14.2156C19.8278 14.041 19.903 13.8519 19.9486 13.6548C20 13.4325 20 13.1973 20 12.7269Z" stroke="#a1a1a1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path> </g></svg>        
        SVG
      end

      # 
      # Get the quote svg.
      # 
      def self.quote_svg
        return <<~SVG
          <svg width="24px" height="24px" 
            viewBox="0 0 24 24" 
            xmlns="http://www.w3.org/2000/svg" 
            fill="#a1a1a1" stroke="#a1a1a1">
            <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
            <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
            <g id="SVGRepo_iconCarrier"> 
              <title></title> 
              <g id="Complete"> 
                <g id="bubble-square"> 
                  <path d="M7.7,18.3H19.4a2.1,2.1,0,0,0,2.1-2.1V4.6a2.1,2.1,0,0,0-2.1-2.1H4.6A2.1,2.1,0,0,0,2.5,4.6V21.5Z" fill="none" stroke="" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></path> 
                </g> 
              </g> 
            </g>
          </svg>
        SVG
      end

      # 
      # Get the info svg.
      # 
      def self.info_svg
        return <<~SVG
          <svg width="24px" height="24px" 
            viewBox="0 0 24 24" 
            xmlns="http://www.w3.org/2000/svg" 
            fill="#2f6eeb">
            <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
            <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
            <g id="SVGRepo_iconCarrier"> 
              <title></title> 
              <g id="Complete"> 
                <g id="info-circle"> 
                  <g> 
                    <circle cx="12" cy="12" data-name="--Circle" fill="none" id="_--Circle" r="10" stroke="#2f6eeb" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"></circle> 
                    <line fill="none" stroke="#2f6eeb" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="12" x2="12" y1="12" y2="16"></line> 
                    <line fill="none" stroke="#2f6eeb" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" x1="12" x2="12" y1="8" y2="8"></line> 
                  </g> 
                </g> 
              </g> 
            </g>
          </svg>
        SVG
      end

    end
  end
end
