# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A MySQL database connection.
#
#
# https://github.com/brianmario/mysql2
# https://www.rubydoc.info/gems/mysql2/0.2.3/Mysql2/Client
#
# Connection Parameters
#   user     = opts[:username]
#   pass     = opts[:password]
#   host     = opts[:host] || 'localhost'
#   port     = opts[:port] || 3306
#   database = opts[:database]
#   socket   = opts[:socket]
#   flags    = opts[:flags] || 0
#
require 'mysql2'

module Gloo
  module Objs
    class Mysql < GlooLang::Core::Obj

      KEYWORD = 'mysql'.freeze
      KEYWORD_SHORT = 'mysql'.freeze

      HOST = 'host'.freeze
      DB = 'database'.freeze
      USER = 'username'.freeze
      PASSWD = 'password'.freeze

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
        fac.create_string HOST, nil, self
        fac.create_string DB, nil, self
        fac.create_string USER, nil, self
        fac.create_string PASSWD, nil, self
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
      # SSH to the host and execute the command, then update result.
      #
      def msg_verify
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
        h = {
          host: host_value,
          database: db_value,
          username: user_value,
          password: passwd_value
        }
        client = Mysql2::Client.new( h )

        heads = []
        data = []
        if params
          pst = client.prepare( sql )
          rs = pst.execute( *params, :as => :array )
          if rs
            rs.each do |row|
              arr = []
              row.each do |o| 
                arr << o
              end
              data << arr
            end
          end
        else
          rs = client.query( sql, :as => :array ) 
          if rs
            rs.each do |row|
              data << row
            end
          end
        end

        heads = rs.fields if rs
        return [ heads, data ]
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Get the host from the child object.
      # Returns nil if there is none.
      #
      def host_value
        o = find_child HOST
        return nil unless o

        o = GlooLang::Objs::Alias.resolve_alias( @engine, o )
        return o.value
      end

      #
      # Get the Database name from the child object.
      # Returns nil if there is none.
      #
      def db_value
        o = find_child DB
        return nil unless o

        o = GlooLang::Objs::Alias.resolve_alias( @engine, o )
        return o.value
      end

      #
      # Get the Username from the child object.
      # Returns nil if there is none.
      #
      def user_value
        o = find_child USER
        return nil unless o

        o = GlooLang::Objs::Alias.resolve_alias( @engine, o )
        return o.value
      end

      #
      # Get the Password name from the child object.
      # Returns nil if there is none.
      #
      def passwd_value
        o = find_child PASSWD
        return nil unless o

        o = GlooLang::Objs::Alias.resolve_alias( @engine, o )
        return o.value
      end

      #
      # Try the connection and make sure it works.
      # Returns true if we can establish a connection.
      #
      def connects?
        begin
          h = {
            host: host_value,
            database: db_value,
            username: user_value,
            password: passwd_value
          }
          Mysql2::Client.new( h )
        rescue => e
          @engine.err e.message
          @engine.heap.it.set_to false
          return false
        end
        return true
      end

    end
  end
end
