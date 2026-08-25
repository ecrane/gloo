# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# The Gloo Script Engine.
# The Engine aggregates all the elements needed to run gloo.
# The Engine runs the main event loop and delegates processing
# to the relevant element.
#

module Gloo
  module App
    class Engine

      # 
      # Constants for the name of the test library.
      # This is the short name as it would be used with the load verb.
      # 
      TEST_LIB_NAME = 'test'

      attr_reader :settings, :log, :running_app
      attr_reader :args, :mode, :running, :platform,
                  :dictionary, :parser, :heap, :factory,
                  :ext_manager, :lib_manager
      attr_accessor :last_cmd, :persist_man, :event_manager,
                    :exec_env, :converter, :context_object

      #
      # Set up the engine with basic elements.
      #
      def initialize( context )
        @args = Args.new( self, context.params )
        @settings = Settings.new( self, context.user_root )

        # Platform (and its theme) needs to be ready before Log is
        # constructed - Log reads engine.theme, which reads through
        # to platform.theme, in its own initialize.
        @platform = context.platform
        @platform.theme = Gloo::App::Theme.new( @settings.theme )

        @log = context.log.new( self, @args.quiet? )
        @log.debug "log (class: #{@log.class.name}) in use ..."
        @log.debug "platform (class: #{@platform.class.name}) in use ..."

        @handling_exception = false
        @handling_error = false
        @log.debug 'engine intialized...'
      end

      #
      # Get the active theme. Platform is the single source of
      # truth for it (Prompt/Table only hold a @platform reference,
      # not an @engine one) - this just reads through to that,
      # rather than keeping a second ivar that could drift out of
      # sync if something reassigns platform.theme directly.
      #
      def theme
        return @platform.theme
      end

      #
      # Start the engine.
      # Load object and verb definitions and setup engine elements.
      #
      def start
        @log.debug 'starting the engine...'
        @log.debug Gloo::App::Info.display_title
        @mode = @args.detect_mode
        @running = true

        @dictionary = Gloo::Core::Dictionary.get

        @parser = Gloo::Core::Parser.new( self )
        @heap = Gloo::Core::Heap.new( self )
        @factory = Gloo::Core::Factory.new( self )
        @persist_man = Gloo::Persist::PersistMan.new( self )
        @event_manager = Gloo::Core::EventManager.new( self )
        @ext_manager = Gloo::Plugin::ExtManager.new( self )
        @lib_manager = Gloo::Plugin::LibManager.new( self )

        @exec_env = Gloo::Exec::ExecEnv.new( self )
        @converter = Gloo::Convert::Converter.new( self )

        @log.info 'The gloo engine has started'
        run_mode
      end

      # 
      # Reset the engine state.
      # Clear out anything that needs clearing or resetting
      # to get the engine back to a clean state.
      #
      def reset_state
        stop_running_app
        @heap = Gloo::Core::Heap.new( self )
        @persist_man = Gloo::Persist::PersistMan.new( self )
      end

      # 
      # Restart the engine with the same settings
      # and the same mode (with files, etc).
      #
      def restart
        @log.info 'Restarting the engine...'
        reset_state
        run_mode
      end


      # ---------------------------------------------------------------------
      #    Run
      # ---------------------------------------------------------------------

      #
      # Run gloo in the selected mode.
      #
      def run_mode
        @log.info "Running gloo in #{@mode} mode"

        if @mode == Mode::VERSION
          run_version
        elsif @mode == Mode::SCRIPT
          run_files
        elsif @mode == Mode::EMBED
          run_keep_alive
        elsif @mode == Mode::APP
          @settings.override_project_path @args.app_path
          run
        elsif @mode == Mode::TEST
          run_test
        else
          run
        end
      end

      #
      # Run files specified on the CLI.
      # Then quit.
      #
      def run_files
        load_files
        quit
      end

      # 
      # Load all file specified in the CLI.
      # 
      def load_files
        @args.files.each { |f| @persist_man.load( f ) }
      end

      # 
      # Run in gloo unit test mode.
      #
      def run_test
        @log.debug 'Running in Test mode…'

        begin
          @lib_manager.load_lib TEST_LIB_NAME
          TestRunner.new( self, @args.files ).run
        rescue => ex
          handle_exception ex
        end

        @log.debug 'Tests complete.'
        quit
      end

      #
      # Run in interactive mode.
      #
      def run
        # Open default file(s)
        self.open_start_file

        # Open any files specifed in args
        load_files

        unless @mode == Mode::SCRIPT || @args.quiet?
          self.loop
        end

        quit
      end

      #
      # Run in Embedded mode, which means we'll
      # start the engine, but wait for external inputs.
      #
      def run_keep_alive
        @log.debug 'Running in Embedded mode…'
      end

      #
      # Get the setting for the start_with file and open it.
      # In App mode, the configured start_with setting is ignored -
      # we always look for a start.gloo at the root of the app
      # (project_path was already overridden to the app path).
      #
      def open_start_file
        if @mode == Mode::APP
          @persist_man.load( 'start' )
          return
        end

        name = @settings.start_with
        @persist_man.load( name ) if name
      end

      #
      # Is the last command entered blank?
      #
      def last_cmd_blank?
        return true if @last_cmd.nil?
        return true if @last_cmd.strip.empty?

        return false
      end

      #
      # Prompt, Get input, process.
      #
      def loop
        while @running
          @last_cmd = @platform.prompt.ask
          process_cmd
        end
      end

      #
      # Process the command.
      #
      def process_cmd cmd=nil
        @last_cmd = cmd if cmd
        
        if last_cmd_blank?
          @platform.clear_screen
          return
        end

        begin
          @parser.run @last_cmd
        rescue => e
          handle_exception e
        end
      end

      #
      # Request the engine to stop running.
      #
      def stop_running
        @running = false
      end

      #
      # Do any clean up and quit.
      #
      def quit
        if app_running?
          @log.debug 'stopping running app...'
          stop_running_app
        end

        @log.debug 'triggering on_quit events...'
        @event_manager.on_quit

        @log.info 'Gloo engine is quitting...'
      end


      # ---------------------------------------------------------------------
      #    Running app within gloo
      # ---------------------------------------------------------------------

      # 
      # Set the running app object within gloo.
      # 
      def start_running_app( obj )
        @running_app = Gloo::App::RunningApp.new( obj, self )
        @running_app.start
      end

      # 
      # Stop the running app object within gloo.
      # 
      def stop_running_app
        @running_app.stop if @running_app
        @running_app = nil
      end

      # 
      # Is there a running app?
      # 
      def app_running?
        return @running_app ? true : false
      end


      # ---------------------------------------------------------------------
      #    Helpers
      # ---------------------------------------------------------------------

      #
      # Show the version information and then quit.
      #
      def run_version
        @platform.show Info.full_version unless @args.quiet?
        quit
      end

      
      # ---------------------------------------------------------------------
      #    Error Handling
      # ---------------------------------------------------------------------

      #
      # Did the last command result in an error?
      #
      def error?
        return !@heap.error.value.nil?
      end

      #
      # Report an error.
      # Write it to the log and set the heap error value. Always logged;
      # runs the on_error script (if any) unless we're already inside
      # one, so a broken handler can't loop.
      #
      def err( msg, backtrace=nil )
        @log.error msg
        @heap.error.set_to msg

        return if @handling_error

        @handling_error = true
        begin
          @event_manager.on_error( msg, backtrace )
        ensure
          @handling_error = false
        end
      end

      #
      # Log an exception.
      # This function does not log the full backtrace, but
      # does write part of it to the log.
      #
      def log_exception ex
        backtrace = format_backtrace( ex )
        @log.error backtrace

        err( ex.message, backtrace)
      end

      #
      # Handle an unanticipated Ruby exception caught at one of the
      # engine's rescue points. Always logged; runs the on_exception
      # script (if any) unless we're already inside one, so a broken
      # handler can't loop.
      #
      def handle_exception ex
        backtrace = format_backtrace( ex )
        @log.error ex.message
        @log.error backtrace

        return if @handling_exception

        @handling_exception = true
        begin
          @event_manager.on_exception( ex.message, backtrace )
        ensure
          @handling_exception = false
        end
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Get the stack trace as a string, truncating the middle if it's long.
      #
      def format_backtrace ex
        msg_lines = ex.backtrace
        if msg_lines.count > 27
          msg_lines = msg_lines[0..13] + [ '... truncated ...' ] + msg_lines[-13..-1]
        end
        return msg_lines.join( "\n" )
      end

    end
  end
end
