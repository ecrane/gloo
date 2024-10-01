# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A Sqlite3 database connection.
#
# https://www.rubydoc.info/gems/sqlite3/1.3.11
# https://www.devdungeon.com/content/ruby-sqlite-tutorial
#
# db.results_as_hash = true
#   Set results to return as Hash object.
#   This is slower but offers a huge convenience.
#   Consider turning it off for high performance situations.
#   Each row will have the column name as the hash key.
#
# # Alternatively, to only get one row and discard the rest,
# replace `db.query()` with `db.get_first_value()`.
#
require 'sqlite3'

module Gloo
  module Objs
    class Sqlite < Gloo::Core::Obj

      KEYWORD = 'sqlite'.freeze
      KEYWORD_SHORT = 'sqlite'.freeze

      DB = 'database'.freeze
      DEFAULT_DB = 'test.db'.freeze

      DB_REQUIRED_ERR = 'The database name is required!'.freeze
      DB_NOT_FOUND_ERR = 'The database file was not found!'.freeze

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
        fac.create_string DB, DEFAULT_DB, self
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'verify' ]
      end

      #
      # Verify access to the Sqlite database specified.
      #
      def msg_verify
        name = db_value
        if name.empty?
          @engine.err DB_REQUIRED_ERR
          @engine.heap.it.set_to false
          return
        end

        unless File.exist? name
          @engine.err DB_NOT_FOUND_ERR
          @engine.heap.it.set_to false
          return
        end

        return unless connects?

        @engine.heap.it.set_to true
      end

      # ---------------------------------------------------------------------
      #    DB functions (all database connections)
      # ---------------------------------------------------------------------

      #
      # Open a connection and execute the SQL statement.
      # Return the resulting data.
      #
      def query( sql, params = nil )
        name = db_value
        unless name
          @engine.err DB_REQUIRED_ERR
          return
        end

        db = SQLite3::Database.open name
        # db.results_as_hash = true
        results = db.query( sql, params )

        return results
      end

      # 
      # Based on the result set, build a QueryResult object.
      # 
      def get_query_result( result )
        rows = []        
        while ( row = result.next ) do
          rows << row
        end

        return QueryResult.new( result.columns, rows )
      end


      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Get the Database file from the child object.
      # Returns nil if there is none.
      #
      def db_value
        o = find_child DB
        return nil unless o

        return o.value
      end

      #
      # Try the connection and make sure it works.
      # Returns true if we can connect and do a query.
      #
      def connects?
        begin
          db = SQLite3::Database.open db_value
          sql = "SELECT COUNT(name) FROM sqlite_master WHERE type='table'"
          db.get_first_value sql
        rescue => e
          @engine.log_exception e
          @engine.heap.it.set_to false
          return false
        end
        return true
      end

    end
  end
end
