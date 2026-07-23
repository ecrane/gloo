# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# A shell runner.  Drives a command-tree REPL with readline
# tab-completion.
#
# Adapted from gloo-cli's ShellRunner: that version took a `Shell`
# Gloo::Core::Obj and read its config (prompt, on_error, etc) from
# gloo-script-declared children. There's no such object tree for an
# interpreter-internal shell, so this version takes plain options
# instead. The Command Obj / cmd_obj_action(_with_context) mechanism
# was gloo-cli's way of running a gloo-declared Command object's
# action script; it isn't ported either — command nodes here always
# dispatch to a named method on the Runner (or a subclass of it).
#
require 'readline'

module Gloo
  module Shell
    class Runner

      DEFAULT_PROMPT = ' -> '.freeze
      UNKNOWN_COMMAND = 'Unknown command'.freeze

      QUIT_NAME = 'quit'.freeze
      QUIT_DESCRIPTION = 'Quit the application'.freeze
      QUIT_METHOD = 'cmd_quit'.freeze

      #
      # Initialize the shell runner.
      #
      # @param engine [Gloo::App::Engine] The running gloo engine.
      #   Not used directly by the base Runner, but stored for
      #   subclasses' command methods to query (dictionary, heap, etc).
      # @param opts [Hash] :prompt, :on_error, :on_unknown_command,
      #   :on_empty_command, :before_action, :after_action - all Procs
      #   except :prompt (String) and :include_quit (Boolean).
      #
      def initialize( engine, opts = {} )
        @engine = engine
        @prompt_text = opts[ :prompt ]
        @on_error = opts[ :on_error ]
        @on_unknown_command = opts[ :on_unknown_command ]
        @on_empty_command = opts[ :on_empty_command ]
        @before_action = opts[ :before_action ]
        @after_action = opts[ :after_action ]
        @include_quit = opts[ :include_quit ] || false

        @context = Gloo::Shell::Context.new
        @root = Gloo::Shell::CommandNode.new( nil )

        add_quit_command if @include_quit
      end

      # ---------------------------------------------------------------------
      #    Shell control: start and stop
      # ---------------------------------------------------------------------

      #
      # Start the shell.
      #
      def start
        repl
      end

      #
      # Flag the shell as done. Next time through the loop it will stop.
      #
      def stop
        @context.done = true
      end

      #
      # Get the prompt string.
      #
      def prompt
        return @prompt_text ? "#{@prompt_text} " : DEFAULT_PROMPT
      end

      #
      # Handle an empty command - run the on_empty_command hook if given.
      #
      def handle_empty_command
        @on_empty_command&.call
      end

      #
      # Handle an unknown command - run the on_unknown_command hook if
      # given, otherwise show the default message.
      #
      def handle_unknown_command
        return if @on_unknown_command&.call

        puts UNKNOWN_COMMAND
      end

      #
      # Run the before_action hook, if given.
      #
      def run_before_action
        @before_action&.call
      end

      #
      # Run the after_action hook, if given.
      #
      def run_after_action
        @after_action&.call
      end

      #
      # Run the on_error hook, if given.
      #
      def run_on_error
        @on_error&.call
      end

      #
      # Quit the shell.
      #
      def cmd_quit( _obj, context )
        puts 'Quitting…'
        context.done = true
      end

      # ---------------------------------------------------------------------
      #    Context
      # ---------------------------------------------------------------------

      #
      # Set a context list, available to dynamic command nodes.
      #
      def set_context( key, value_list )
        @context.set( key, value_list )
      end

      # ---------------------------------------------------------------------
      #    Tree building
      # ---------------------------------------------------------------------

      #
      # Execute a command.
      #
      def execute_command( command_node, _args, _parent_node = nil )
        if command_node.method
          send( command_node.method, command_node.obj, @context )
        elsif command_node.name && !command_node.description.empty?
          puts "#{command_node.description}: #{command_node.name}"
        end
      end

      #
      # Build a command node from data.
      #
      def build_node_from_data( data )
        if data[ :dynamic ]
          return Gloo::Shell::CommandNode.new(
            data[ :name ], description: data[ :description ], obj: data[ :obj ] ) do |ctx|
            ctx.send( data[ :source ] ).map { |item| Gloo::Shell::CommandNode.new( item ) }
          end
        elsif data[ :children ]
          return Gloo::Shell::CommandNode.new(
            data[ :name ], description: data[ :description ],
            method: data[ :method ], obj: data[ :obj ] ) do |_ctx|
            data[ :children ].map { |child_data| build_node_from_data( child_data ) }
          end
        else
          return Gloo::Shell::CommandNode.new(
            data[ :name ], description: data[ :description ],
            method: data[ :method ], obj: data[ :obj ] )
        end
      end

      #
      # Add a command node to the root, dynamically.
      #
      # @param command_data [Hash] The command data hash.
      #
      def add_command_node( command_data )
        node = build_node_from_data( command_data )

        existing_block = @root.instance_variable_get( :@children_block )
        if existing_block
          existing_nodes = existing_block.call( @context )
          all_nodes = existing_nodes + [ node ]
          @root.instance_variable_set( :@children_block, proc { |_ctx| all_nodes } )
        else
          @root.instance_variable_set( :@children_block, proc { |_ctx| [ node ] } )
        end

        return node
      end

      # ---------------------------------------------------------------------
      #    REPL
      # ---------------------------------------------------------------------

      #
      # Execute a single command from the given tokens and return.
      #
      def execute_once( tokens )
        result = traverse( @root, tokens )
        if result[ :node ]
          run_before_action
          execute_command( result[ :node ], tokens, result[ :parent ] )
          run_after_action
        else
          handle_unknown_command
        end
      end

      #
      # Traverse the command tree to find the matching node.
      #
      # @param node [CommandNode] The current node.
      # @param tokens [Array<String>] The tokens to traverse.
      #
      # @return [Hash] Hash with :node and :parent keys.
      #
      def traverse( node, tokens )
        current = node
        parent = nil

        tokens.each do |token|
          children = current.children( @context )
          match = children.find { |c| c.name == token }
          return { node: nil, parent: nil } unless match

          parent = current
          current = match
        end

        return { node: current, parent: parent }
      end

      #
      # Setup readline completion.
      #
      def setup_completion
        Readline.completion_append_character = ' '
        Readline.basic_word_break_characters = " \t\n\"\\'`@$><=;|&{("

        Readline.completion_proc = proc do |input|
          buffer = Readline.line_buffer
          tokens = buffer.split( ' ' )
          tokens << '' if buffer.end_with?( ' ' )

          result = traverse( @root, tokens[ 0..-2 ] )
          current = result[ :node ]
          options = current ? current.children( @context ).map( &:name ) : []

          matches = options.grep( /^#{Regexp.escape( input )}/ )

          if matches.length > 1
            puts
            current.children( @context ).each do |child|
              puts "#{child.name.ljust( 15 )} #{child.description}" if matches.include?( child.name )
            end
            print "#{prompt}#{buffer}"
          end

          matches
        end
      end

      #
      # Run the REPL loop.
      #
      def repl
        setup_completion

        while !@context.done && ( line = Readline.readline( prompt, true ) )
          tokens = line.strip.split( ' ' )
          if tokens.empty?
            handle_empty_command
            next
          end

          result = traverse( @root, tokens )

          if result[ :node ]
            run_before_action
            execute_command( result[ :node ], tokens, result[ :parent ] )
            run_after_action
          else
            handle_unknown_command
          end
        end
      end

      # ---------------------------------------------------------------------
      #    Private
      # ---------------------------------------------------------------------

      private

      #
      # Add the built-in quit command, if enabled.
      #
      def add_quit_command
        add_command_node(
          { name: QUIT_NAME, description: QUIT_DESCRIPTION, method: QUIT_METHOD } )
      end

    end
  end
end
