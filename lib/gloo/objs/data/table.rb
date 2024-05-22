# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A data table.
# The table container headers and data.
#

module Gloo
  module Objs
    class Table < Gloo::Core::Obj

      KEYWORD = 'table'.freeze
      KEYWORD_SHORT = 'tbl'.freeze
      HEADERS = 'headers'.freeze
      DATA = 'data'.freeze
      STYLES = 'styles'.freeze

      #
      # The name of the object type.
      #
      def self.typename
        return KEYWORD
      end

      #
      # The short name of the object type.
      #
      def self.short_typename
        return KEYWORD_SHORT
      end

      #
      # Get the list of headers.
      # Returns nil if there is none.
      #
      def headers
        o = find_child HEADERS
        return [] unless o

        return o.children.map( &:value )
      end

      #
      # Get the list of column names.
      # Returns nil if there is none.
      #
      def columns
        o = find_child HEADERS
        return [] unless o

        return o.children.map( &:name )
      end

      #
      # Get the list of data elements.
      #
      def data
        o = find_child DATA
        return [] unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        
        if o.is_a? Gloo::Objs::Query
          @engine.log.info "Table getting data from query."
          result = o.run_query
          return result
        else
          cols = self.columns
          return o.children.map do |e|
            cols.map { |h| e.find_child( h ).value }
          end
        end
      end

      # 
      # Get the styles for the table, if any.
      # 
      def styles
        style_h = {} 
        o = find_child STYLES
        return style_h unless o
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )

        o.children.each do |c|
          style_h[ c.name ] = c.value
        end

        return style_h
      end

      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      #
      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      #
      def add_children_on_create?
        return true
      end

      #
      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      #
      def add_default_children
        fac = @engine.factory
        fac.create_can HEADERS, self
        fac.create_can DATA, self
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + %w[show render]
      end

      #
      # Show the table in the CLI.
      #
      def msg_show
        title = self.value
        @engine.platform.show_table headers, data, title
      end

      def msg_render
        return render
      end

      # ---------------------------------------------------------------------
      #    Render
      # ---------------------------------------------------------------------

      # 
      # Render the table.
      # The render_ƒ is 'render_html', 'render_text', 'render_json', etc.
      # 
      def render render_ƒ
        result = self.data
        head = self.headers 
        head = result[0] if head.empty?
        rows = result[1]

        helper = Gloo::WebSvr::TableRenderer.new( @engine )
        return helper.data_to_table( head, rows, self.styles )
      end

    end
  end
end
