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

      attr_reader :settings, :log, :running_app
      attr_reader :args, :mode, :running, :platform,
                  :dictionary, :parser, :heap, :factory,
                  :ext_manager
      attr_accessor :last_cmd, :persist_man, :event_manager,
                    :exec_env, :converter

      #
      # Set up the engine with basic elements.
      #
      def initialize( context )
        @args = Args.new( self, context.params )
        @settings = Settings.new( self, context.user_root )

        @log = context.log.new( self, @args.quiet? )
        @log.debug "log (class: #{@log.class.name}) in use ..."

        @platform = context.platform
        @log.debug "platform (class: #{@platform.class.name}) in use ..."

        @log.debug 'engine intialized...'
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
        @ext_manager = Gloo::Ext::Manager.new( self )

        @exec_env = Gloo::Exec::ExecEnv.new( self )
        @converter = Gloo::Convert::Converter.new( self )

        @log.info 'The gloo engine has started'
        run_mode
      end


      # ---------------------------------------------------------------------
      #    Serialization
      # ---------------------------------------------------------------------

      #
      # Prepare for serialization by removing any file references.
      # Without this, the engine cannot be serialized.
      #
      def prep_serialize
        @log.prep_serialize
      end

      #
      # Get the serialized version of this Engine.
      #
      def serialize
        prep_serialize
        Marshal::dump( self )
      end

      #
      # Deserialize the Engine data.
      #
      def self.deserialize data
        e = Marshal::load( data )
        e.restore_after_deserialization
        return e
      end

      #
      # Restore the engine after deserialization.
      #
      def restore_after_deserialization
        @log.restore_after_deserialization
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
        @log.debug 'Running in Embedded mode...'
      end

      #
      # Get the setting for the start_with file and open it.
      #
      def open_start_file
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
          log_exception e
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
      # Write it to the log and set the heap error value.
      #
      def err( msg, backtrace=nil )
        @log.error msg
        @heap.error.set_to msg

        @event_manager.on_error( msg, backtrace)
      end

      # 
      # Log an exception.
      # This function does not log the full backtrace, but 
      # does write part of it to the log.
      # 
      def log_exception ex
        # Get the stack trace, and if needed truncate to fit.
        msg_lines = ex.backtrace
        if msg_lines.count > 27
          msg_lines = msg_lines[0..13] + [ '... truncated ...' ] + msg_lines[-13..-1]
        end
        backtrace = msg_lines.join( "\n" )
        @log.error backtrace

        err( ex.message, backtrace)
      end
        
    end
  end
end
