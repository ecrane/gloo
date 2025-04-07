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
      CELLS = 'cells'.freeze
      STYLES = 'styles'.freeze
      ALWAYS_ROWS = 'always_rows'.freeze

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
      # Always show rows, even if only 1 row is found.
      #
      def always_rows
        o = find_child ALWAYS_ROWS

        return false unless o
        return o.value
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
          @engine.log.debug "Table getting data from query."
          begin
            result = o.run_query
            return result
          rescue => e
            @engine.log_exception e
            return nil
          end
        else
          cols = self.columns

          if o.children&.first.children.empty?
            # It is a simgle row table.
            rows = [ cols.map { |h| o.find_child( h )&.value } ]
          else
            rows = o.children.map do |e|
              cols.map { |h| e.find_child( h )&.value }
            end
          end

          return [ cols, rows ]
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

      # 
      # Get cell renderer hash keyed by column name.
      # 
      def cell_renderers
        h = {}
        o = find_child CELLS
        return h unless o

        o.children.each do |c|
          h[ c.name ] = c.value
        end

        return h
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
        @engine.platform.table.show headers, data[1], title
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
        begin
          result = self.data
          head = self.headers 
          head = result[0] if head.empty?
          rows = result[1]

          columns = build_columns result[0]

          params = { 
            head: head, 
            cols: result[0],
            columns: columns,
            rows: rows,
            styles: self.styles,
            cell_renderers: self.cell_renderers
          }

          if self.always_rows
            params[ :always_rows ] = true
          end

          helper = Gloo::WebSvr::TableRenderer.new( @engine )
          return helper.data_to_table params
        rescue => e
          @engine.log_exception e
          return nil
        end
      end

      # 
      # Build the column list based on the result data and
      # the headers defined in the table object.
      # 
      def build_columns result_data
        head_children = find_child HEADERS
        cell_renderers = find_child CELLS

        columns = []
        return columns unless result_data
        
        result_data.each_with_index do |c,index|
          visible = true
          name = c
          title = c
          display_index = index

          if head_children
            child = head_children.find_child c
            if child
              title = child.value
              display_index = head_children.child_index( c )
            else
              visible = false
            end
          end

          cell_renderer = nil
          if cell_renderers
            this_cr = cell_renderers.find_child( c )
            cell_renderer = this_cr.value if this_cr
          end

          columns << { 
            name: name, 
            title: title, 
            visible: visible, 
            data_index: index,
            display_index: display_index,
            cell_renderer: cell_renderer
          }
        end
        return columns.sort_by { |hsh| hsh[ :display_index ] }
      end

    end
  end
end
