# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A SQL database query.
# Relies on a database connection object.
#

module Gloo
  module Objs
    class Query < Gloo::Core::Obj

      KEYWORD = 'query'.freeze
      KEYWORD_SHORT = 'sql'.freeze

      DB = 'database'.freeze
      SQL = 'sql'.freeze
      RESULT = 'result'.freeze
      PARAMS = 'params'.freeze
      SIMPLE_LIST = 'simple_list'.freeze

      DB_MISSING_ERR = 'The database connection is missing!'.freeze

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
        fac.create_alias DB, nil, self
        fac.create_string SQL, nil, self
        fac.create_can RESULT, self
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'run' ]
      end

      #
      # Run the query and process the results.
      #
      def msg_run
        db = db_obj
        return unless db

        begin
          result = db.query( sql_value, param_array )
          process_result( result, db )
        rescue => e
          @engine.log_exception e
          return
        end
      end

      #
      # Run the query and return the results.
      #
      def run_query
        db = db_obj
        return unless db

        begin
          log_query sql_value, param_array

          db_start = ::Time.now
          result = db.query( sql_value, param_array )
          db_done = ::Time.now
          elapsed = ( ( db_done - db_start ) * 1000.0 ).round(2)
  
          app = @engine.running_app
          app.add_db_time elapsed if app
          return result
        rescue => e
          @engine.log_exception e
          return
        end
      end

      # 
      # Write the query to the log.
      # 
      def log_query sql, params
        @engine.log.info "QUERY PARAMS: #{params}" if params
        @engine.log.info "QUERY: #{sql}"
      end


      # ---------------------------------------------------------------------
      #    Output as simple list
      # ---------------------------------------------------------------------

      # 
      # Should the output be put in a simple list?
      # 
      def simple_list?
        o = find_child SIMPLE_LIST
        return false unless o

        return o.value
      end


      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Get the database connection.
      #
      def db_obj
        o = find_child DB

        unless o
          @engine.err DB_MISSING_ERR
          return nil
        end

        return Gloo::Objs::Alias.resolve_alias( @engine, o )
      end

      #
      # Get the SQL from the child object.
      # Returns nil if there is none.
      #
      def sql_value
        o = find_child SQL
        return nil unless o

        return o.value
      end

      #
      # Do something with the result of the SQL Query call.
      # If there's a result container, we'll create objects in it.
      # If not, we'll just show the output in the console.
      #
      def process_result( result, db )
        return if result.nil?

        query_result = db.get_query_result( result )
        return unless query_result
        return unless query_result.has_data_to_show?

        result_can = find_child RESULT
        result_can = Gloo::Objs::Alias.resolve_alias( @engine, result_can )

        if result_can
          if simple_list?
            query_result.update_result_container_simple result_can
          else
            query_result.update_result_container result_can
          end
        else
          query_result.show
        end
      end

      #
      # Get the array of parameters.
      # If there is no PARAM container of if it is empty,
      # we'll return a nil value.
      #
      def param_array
        o = find_child PARAMS
        return nil unless o

        return nil if o.child_count.zero?

        params = []
        o.children.each do |p|
          p = Gloo::Objs::Alias.resolve_alias( @engine, p )
          params << p.sql_value
        end

        return params
      end


    end
  end
end
