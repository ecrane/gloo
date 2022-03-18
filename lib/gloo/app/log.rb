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
    class Log < GlooLang::App::Log

      #
      # Write an information message to the log.
      # Also write to the console unless quiet.
      #
      def info( msg )
        @logger.info msg
        puts msg.blue unless @quiet
      end

      #
      # Write a warning message to the log.
      # Also write to the console unless quiet.
      #
      def warn( msg )
        @logger.warn msg
        puts msg.yellow unless @quiet
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
