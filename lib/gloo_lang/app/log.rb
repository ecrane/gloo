# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Application Logging wrapper.
#
require 'active_support'

module GlooLang
  module App
    class Log

      attr_accessor :quiet
      attr_reader :logger

      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up a logger.
      # If quiet is true, then message are written to the log
      # but not to the console.
      #
      def initialize( engine, quiet=true )
        @engine = engine
        @quite = quiet

        create_logger

        debug 'log intialized...'
      end

      #
      # Create the default [file] logger.
      #
      def create_logger
        f = File.join( @engine.settings.log_path, 'gloo.log' )
        @logger = Logger.new( f )
        @logger.level = Logger::DEBUG
      end

      # ---------------------------------------------------------------------
      #    Standard Output
      # ---------------------------------------------------------------------

      #
      # Show a message unless we're in quite mode.
      #
      def show( msg )
        puts msg unless @quiet
      end

      # ---------------------------------------------------------------------
      #    Logging functions
      # ---------------------------------------------------------------------

      #
      # Write a debug message to the log.
      #
      def debug( msg )
        @logger.debug msg
      end

      #
      # Write an information message to the log.
      # Also write to the console unless quiet.
      #
      def info( msg )
        @logger.info msg
        puts msg unless @quiet
      end

      #
      # Write a warning message to the log.
      # Also write to the console unless quiet.
      #
      def warn( msg )
        @logger.warn msg
        puts msg unless @quiet
      end

      #
      # Write an error message to the log and set the error
      # in the engine's data heap.
      # Also write to the console unless quiet.
      #
      def error( msg, ex = nil, engine = nil )
        engine&.heap&.error&.set_to msg
        @logger.error msg
        if ex
          @logger.error ex.message
          @logger.error ex.backtrace
          puts msg unless @quiet
          puts ex.message unless @quiet
          puts ex.backtrace unless @quiet
        else
          puts msg unless @quiet
        end
      end

      # ---------------------------------------------------------------------
      #    Serialization
      # ---------------------------------------------------------------------

      #
      # Prepare for serialization by removing the file reference.
      # Without this, the engine cannot be serialized.
      #
      def prep_serialize
        @logger = nil
      end

      #
      # Restore the logger after deserialization.
      #
      def restore_after_deserialization
        create_logger
      end

    end
  end
end
