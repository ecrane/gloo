# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# An object that can post JSON to a URI.
#
require 'net/ssh'

module Gloo
  module Objs
    class SshExec < GlooLang::Core::Obj

      KEYWORD = 'ssh_exec'.freeze
      KEYWORD_SHORT = 'ssh'.freeze
      HOST = 'host'.freeze
      DEFAULT_HOST = 'localhost'.freeze
      CMD = 'cmd'.freeze
      RESULT = 'result'.freeze
      HOST_REQUIRED_ERR = 'The host is required!'.freeze

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
        fac.create_string HOST, DEFAULT_HOST, self
        fac.create_string CMD, nil, self
        fac.create_string RESULT, nil, self
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
      # SSH to the host and execute the command, then update result.
      #
      def msg_run
        h = host_value
        unless h
          @engine.err HOST_REQUIRED_ERR
          return
        end

        Net::SSH.start( h ) do |ssh|
          result = ssh.exec!( cmd_value )
          update_result result
        end
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

        return o.value
      end

      #
      # Get the command from the child object.
      # Returns nil if there is none.
      #
      def cmd_value
        o = find_child CMD
        return nil unless o

        return o.value
      end

      #
      # Set the result of the API call.
      #
      def update_result( data )
        r = find_child RESULT
        return nil unless r

        r.set_value data
      end

    end
  end
end
