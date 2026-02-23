# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Arguments (parameters) used to specify functionality.
# These might have come from the CLI or as parameters
# in the constructor.
#
require 'active_support'

module Gloo
  module App
    class Args

      QUIET = 'quiet'.freeze
      GLOO_ENV = 'GLOO_ENV'.freeze

      attr_reader :switches, :files, :app_path

      #
      # Create arguments and setup.
      #
      def initialize( engine, params = [] )
        @engine = engine
        @switches = []
        @files = []
        @app_path = nil

        params.each { |o| process_one_arg( o ) }
        ARGV.each { |o| process_one_arg( o ) }
      end

      #
      # Was the --quiet arg passed?
      #
      def quiet?
        return @switches.include?( QUIET )
      end

      #
      # Is the app switch set?
      #
      def app?
        @switches.include?( Gloo::App::Mode::APP.to_s )
      end

      # 
      # Make sure that if we are running in App mode
      # that the app path has been set and is a valid path.
      # 
      def verify_app_mode
        return true unless app?

        if @app_path.nil?
          @engine.err "App Path required to run in App mode."
          return false
        end

        unless File.directory? @app_path
          @engine.err "'#{@app_path}' is not a valid directory."
          return false
        end

        @engine.log.info "App root directory: '#{@app_path}'."
        return true
      end

      #
      # Is the version switch set?
      #
      def version?
        @switches.include?( Gloo::App::Mode::VERSION.to_s )
      end

      #
      # Is the help switch set?
      #
      def help?
        @switches.include?( Gloo::App::Mode::HELP.to_s )
      end

      #
      # Is the cli switch set?
      #
      def cli?
        @switches.include?( Gloo::App::Mode::CLI.to_s )
      end

      #
      # Is the embed switch set?
      #
      def embed?
        @switches.include?( Gloo::App::Mode::EMBED.to_s )
      end

      #
      # Is the test switch set?
      #
      def test?
        @switches.include?( Gloo::App::Mode::TEST.to_s )
      end

      #
      # Detect the mode to be run in.
      # Start by seeing if a mode is specified.
      # Then look for the presence of files.
      # Then finally use the default: embedded mode.
      #
      def detect_mode
        mode = if ENV[ GLOO_ENV ] == Gloo::App::Mode::TEST.to_s
                 Mode::TEST
               elsif app?
                 Mode::APP
               elsif version?
                 Mode::VERSION
               elsif help?
                 Mode::HELP
               elsif cli?
                 Mode::CLI
               elsif embed?
                 Mode::EMBED
               elsif test?
                 Mode::TEST
               elsif @files.count.positive?
                 Mode::SCRIPT
               else
                 Mode.default_mode
               end

        mode = Mode::CLI unless verify_app_mode
        @engine.log.debug "running in #{mode} mode"

        return mode
      end

      # ---------------------------------------------------------------------
      #    Private
      # ---------------------------------------------------------------------

      private

      #
      # Process one argument or parameter.
      #
      def process_one_arg( arg )
        if arg.start_with? '--'
          switches << arg[ 2..-1 ]
        elsif app? && ( @app_path.nil? )
          @app_path = arg
        else
          files << arg
        end
      end

    end
  end
end
