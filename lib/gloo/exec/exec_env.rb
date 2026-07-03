# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# The execution environment.
# The current state of running scripts and messaging.
#

module Gloo
  module Exec
    class ExecEnv

      attr_accessor :verbs, :actions, :scripts, :here
      attr_reader :running_script

      VERB_STACK = 'verbs'.freeze
      ACTION_STACK = 'actions'.freeze
      SCRIPT_STACK = 'scripts'.freeze
      HERE_STACK = 'here'.freeze

      #
      # Set up the execution environment.
      #
      def initialize( engine )
        @engine = engine
        @engine.log.debug 'exec env intialized...'
        @running_script = nil

        @verbs = Gloo::Exec::Stack.new( @engine, VERB_STACK )
        @actions = Gloo::Exec::Stack.new( @engine, ACTION_STACK )
        @scripts = Gloo::Exec::Stack.new( @engine, SCRIPT_STACK )
        @here = Gloo::Exec::Stack.new( @engine, HERE_STACK )
      end

      #
      # Get the here object.
      #
      def here_obj
        return nil if @here.stack.empty?

        return @here.stack.last
      end

      #
      # Push a script onto the stack.
      #
      def push_script( script )
        @scripts.push script
        @running_script = script
        @here.push script.obj
      end

      #
      # Pop a script off the stack.
      #
      def pop_script
        @scripts.pop
        @running_script = @scripts.stack.last
        @here.pop
      end

      #
      # Push an action onto the stack.
      #
      def push_action( action )
        @actions.push action
      end

      #
      # Pop an action off the stack.
      #
      def pop_action
        @actions.pop
      end

    end
  end
end
