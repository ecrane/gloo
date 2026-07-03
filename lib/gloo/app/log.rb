# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Application Logging wrapper.
#
require 'active_support'
require 'colorize'
require 'colorized_string'

module Gloo
  module App
    class Log

      DEBUG = 'debug'.freeze
      INFO = 'info'.freeze
      WARN = 'warn'.freeze
      ERROR = 'error'.freeze
      LEVELS = [ DEBUG, INFO, WARN, ERROR ].freeze

      CLEARED = "\n\n --- Log files cleared. --- \n\n".freeze

      LOG_FILE = 'gloo.log'.freeze
      ERROR_FILE = 'error.log'.freeze

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
      def initialize( engine, quiet = true )
        @engine = engine
        @quiet = quiet
        @debug = engine.settings.debug

        create_loggers

        debug 'log intialized...'
      end

      #
      # Create the default [file] logger.
      #
      def create_loggers
        @logger = Logger.new( log_file )
        @logger.level = Logger::DEBUG

        @error = Logger.new( err_file )
        @error.level = Logger::WARN
      end

      # ---------------------------------------------------------------------
      #    Files
      # ---------------------------------------------------------------------

      #
      # Get the log file.
      #
      def log_file
        return File.join( @engine.settings.log_path, LOG_FILE )
      end

      #
      # Get the error log file.
      #
      def err_file
        return File.join( @engine.settings.log_path, ERROR_FILE )
      end

      # ---------------------------------------------------------------------
      #    Static Helpers
      # ---------------------------------------------------------------------

      #
      # Does the given str represent a logging level?
      #
      def self.is_level?( str )
        return false unless str.is_a? String

        return LEVELS.include? str.strip.downcase
      end

      # ---------------------------------------------------------------------
      #    Log file clearing
      # ---------------------------------------------------------------------

      #
      # Clear the log files.
      #
      def clear
        File.write( log_file, CLEARED )
        File.write( err_file, CLEARED )

        create_loggers
      end

      # ---------------------------------------------------------------------
      #    Standard Output
      # ---------------------------------------------------------------------

      #
      # Show a message unless we're in quite mode.
      #
      def show( msg, color = nil )
        return if @quiet

        if color
          puts ColorizedString[ msg ].colorize( color.to_sym )
        else
          puts msg
        end
      end

      # ---------------------------------------------------------------------
      #    Logging functions
      # ---------------------------------------------------------------------

      #
      # Write to the specified level.
      #
      def write( msg, level )
        if level == DEBUG
          debug msg
        elsif level == INFO
          info msg
        elsif level == WARN
          warn msg
        elsif level == ERROR
          error msg
        end
      end

      #
      # Write a debug message to the log.
      #
      def debug( msg )
        return unless @debug

        @logger.debug msg
      end

      #
      # Write an information message to the log.
      #
      def info( msg )
        @logger.info msg
        # puts msg.blue unless @quiet
      end

      #
      # Write a warning message to the log.
      # Also write to the console unless quiet.
      #
      def warn( msg )
        @logger.warn msg
        @error.warn msg
        puts msg.yellow unless @quiet
      end

      #
      # Write an error message to the log and set the error
      # in the engine's data heap.
      # Also write to the console unless quiet.
      #
      def error( msg, ex = nil, engine = nil )
        engine&.heap&.error&.set_to( msg ) if engine
        @logger.error msg
        @error.error msg
        if ex
          @error.error ex.message
          @error.error ex.backtrace
          puts msg.red unless @quiet
          puts ex.message.red unless @quiet
          puts ex.backtrace unless @quiet
        else
          puts msg.red unless @quiet
        end
      end

    end
  end
end
