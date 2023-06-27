# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# The System Object.
# A virtual Object: the system object can be used to access
# system level variables and functions.  But it is not
# actually an object in the normal sense of the word.
#
require 'tty-platform'
require 'os'

module Gloo
  module Core
    class GlooSystem < Obj

      KEYWORD = 'gloo'.freeze
      KEYWORD_SHORT = '$'.freeze

      attr_reader :pn

      # Set up the object.
      def initialize( engine, pn )
        @engine = engine
        @pn = pn
      end

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
      # The object type, suitable for display.
      #
      def type_display
        return self.class.typename
      end

      # Is this the root object?
      def root?
        return false
      end

      # Can this object be created?
      # This is true by default and only false for some special cases
      # such as the System object.
      def self.can_create?
        false
      end

      # ---------------------------------------------------------------------
      #    Value
      # ---------------------------------------------------------------------

      #
      # Get the parameter.
      #
      def param
        return nil unless @pn && @pn.segments.count > 1

        return @pn.segments[ 1..-1 ].join( '_' )
      end

      #
      # Get the system value.
      #
      def value
        return dispatch param
      end

      #
      # There is no value object in the system.
      #
      def set_value( new_value )
        # overriding base functionality with dummy function
      end

      #
      # Get the value for display purposes.
      #
      def value_display
        return value
      end

      #
      # Is the value a String?
      #
      def value_string?
        return true
      end

      #
      # Is the value an Array?
      #
      def value_is_array?
        return false
      end

      #
      # Is the value a blank string?
      #
      def value_is_blank?
        return true
      end

      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      def add_children_on_create?
        return false
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return []
      end

      # Dispatch the message and get the value.
      def dispatch( msg )
        o = "msg_#{msg}"
        return self.public_send( o ) if self.respond_to? o

        @engine.log.error "Message #{msg} not implemented"
        return false
      end

      # Get the system hostname.
      def msg_hostname
        return Socket.gethostname
      end

      # Get the logged in User.
      def msg_user
        return ENV[ 'USER' ]
      end

      # Get the user's home directory.
      def msg_user_home
        return File.expand_path( '~' )
      end

      # Get the working directory.
      def msg_working_dir
        return Dir.pwd
      end

      # Get the Gloo home directory
      def msg_gloo_home
        return @engine.settings.user_root
      end

      # Get the Gloo configuration directory
      def msg_gloo_config
        return @engine.settings.config_path
      end

      # Get the Gloo projects directory
      def msg_gloo_projects
        return @engine.settings.project_path
      end

      # Get the Gloo log directory
      def msg_gloo_log
        return @engine.settings.log_path
      end

      # ---------------------------------------------------------------------
      #    Special chars
      # ---------------------------------------------------------------------

      # Carriage return (line feed)
      def msg_line
        return "\n"
      end

      # ---------------------------------------------------------------------
      #    Screen Messages
      # ---------------------------------------------------------------------

      # Get the number of lines on screen.
      def msg_screen_lines
        return Gloo::App::Settings.lines( @engine )
      end

      # Get the number of columns on screen.
      def msg_screen_cols
        return Gloo::App::Settings.cols( @engine )
      end

      # ---------------------------------------------------------------------
      #    Platform Messages
      # ---------------------------------------------------------------------

      # Get the platform CPU
      def msg_platform_cpu
        platform = TTY::Platform.new
        return platform.cpu
      end

      # Get the platform Operating System
      def msg_platform_os
        platform = TTY::Platform.new
        return platform.os
      end

      # Get the platform version
      def msg_platform_version
        platform = TTY::Platform.new
        return platform.version
      end

      # Is the platform Windows?
      def msg_platform_windows?
        return OS.windows?
      end

      # Is the platform Unix?
      def msg_platform_unix?
        platform = TTY::Platform.new
        return platform.unix?
      end

      # Is the platform Linux?
      def msg_platform_linux?
        platform = TTY::Platform.new
        return platform.linux?
      end

      # Is the platform Mac?
      def msg_platform_mac?
        return OS.mac?
      end

      #
      # Get the command to open a file on this platform.
      #
      def self.open_for_platform
        platform = TTY::Platform.new
        return 'open' if platform.mac?
        return 'xdg-open' if platform.linux?
        
        return 'Start-Process' if OS.windows?

        return nil
      end

    end
  end
end
