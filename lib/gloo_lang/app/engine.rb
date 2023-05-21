# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# The Gloo Script Engine.
# The Engine aggregates all the elements needed to run gloo.
# The Engine runs the main event loop and delegates processing
# to the relevant element.
#

module GlooLang
  module App
    class Engine

      attr_reader :settings, :log
      attr_reader :args, :mode, :running, :platform,
                  :dictionary, :parser, :heap, :factory
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

        @dictionary = GlooLang::Core::Dictionary.get

        @parser = GlooLang::Core::Parser.new( self )
        @heap = GlooLang::Core::Heap.new( self )
        @factory = GlooLang::Core::Factory.new( self )
        @persist_man = Gloo::Persist::PersistMan.new( self )
        @event_manager = GlooLang::Core::EventManager.new( self )

        @exec_env = Gloo::Exec::ExecEnv.new( self )
        @converter = GlooLang::Convert::Converter.new( self )

        @log.debug 'the engine has started'
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
        @log.debug "running gloo in #{@mode} mode"

        if @mode == Mode::VERSION
          run_version
        elsif @mode == Mode::SCRIPT
          run_files
        elsif @mode == Mode::EMBED
          run_keep_alive
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
          @last_cmd = @platform.prompt_cmd
          process_cmd
        end
      end

      #
      # Process the command.
      #
      def process_cmd
        if last_cmd_blank?
          @platform.clear_screen
          return
        end

        @parser.run @last_cmd
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
        @log.debug 'quitting...'
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
      def err( msg )
        @log.error msg
        @heap.error.set_to msg
      end

    end
  end
end
