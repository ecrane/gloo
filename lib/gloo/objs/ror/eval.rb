# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that evaluate a ruby statement.
#

module Gloo
  module Objs
    class Eval < Gloo::Core::Obj

      KEYWORD = 'eval'.freeze
      KEYWORD_SHORT = 'ruby'.freeze
      CMD = 'command'.freeze
      RESULT = 'result'.freeze

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
      # Get the URI from the child object.
      # Returns nil if there is none.
      #
      def cmd_value
        cmd = find_child CMD
        return nil unless cmd

        return cmd.value
      end

      #
      # Set the result of the system call.
      #
      def set_result( data )
        r = find_child RESULT
        return nil unless r

        r.set_value data
      end

      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      def add_children_on_create?
        return true
      end

      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      def add_default_children
        fac = $engine.factory
        fac.create( { :name => 'command',
                      :type => 'string',
                      :value => '1+2',
                      :parent => self } )
        fac.create( { :name => 'result',
                      :type => 'string',
                      :value => nil,
                      :parent => self } )
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

      # Run the system command.
      def msg_run
        cmd = cmd_value
        return unless cmd

        begin
          # rubocop:disable Security/Eval
          result = eval cmd
          # rubocop:enable Security/Eval
          set_result result
          $engine.heap.it.set_to result
        rescue => e
          $log.error e.message
          $engine.heap.error.set_to e.message
        end
      end

      # ---------------------------------------------------------------------
      #    Help
      # ---------------------------------------------------------------------

      #
      # Get help for this object type.
      #
      def self.help
        return <<~TEXT
          EVAL OBJECT TYPE
            NAME: eval
            SHORTCUT: ruby

          DESCRIPTION
            Execute a ruby expression.

          CHILDREN
            command - string
              The ruby expression or command that will be run.
            result - string
              The result of the command or expression after it is run.

          MESSAGES
            run - Execute the ruby command and update the result.
        TEXT
      end

    end
  end
end
