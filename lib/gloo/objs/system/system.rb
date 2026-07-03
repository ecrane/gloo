# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that can make a system call.
#

module Gloo
  module Objs
    class System < Gloo::Core::Obj

      KEYWORD = 'system'.freeze
      KEYWORD_SHORT = 'sys'.freeze
      CMD = 'command'.freeze
      DEFAULT_CMD = 'date'.freeze
      RESULT = 'result'.freeze
      GET_OUTPUT = 'get_output'.freeze

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
      # Get the command from the child object.
      # Returns nil if there is none.
      #
      def cmd_value
        return find_child_value CMD
      end

      #
      # Set the result of the system call.
      #
      def set_result( data )
        r = find_child_resolve_alias RESULT
        return unless r

        r.set_value data
      end

      #
      # Should the system call get output?
      # If so, the system call will run and get output,
      # otherwise it will just get the result of the call.
      #
      def output?
        return find_child_value GET_OUTPUT
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
        fac.create_string CMD, DEFAULT_CMD, self
        fac.create_bool GET_OUTPUT, true, self
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
      # Run the system command.
      #
      def msg_run
        if output?
          run_with_output
        else
          run_with_result
        end
      end

      #
      # Run the command and collect output.
      #
      def run_with_output
        cmd = cmd_value
        return unless cmd

        result = `#{cmd}`
        set_result result
      end

      #
      # Run the command and set the result.
      #
      def run_with_result
        cmd = cmd_value
        return unless cmd

        result = system cmd
        set_result result
      end

    end
  end
end
