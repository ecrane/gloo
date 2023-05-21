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
        cols = self.columns
        return o.children.map do |e|
          cols.map { |h| e.find_child( h ).value }
        end
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
        return super + %w[show]
      end

      #
      # Show the table in the CLI.
      #
      def msg_show
        title = self.value
        @engine.platform.show_table headers, data, title
      end

    end
  end
end
