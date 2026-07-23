# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# The System Object.
# A virtual Object: the system object can be used to access
# system level variables and functions.  But it is not
# actually an object in the normal sense of the word.
#
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

        @engine.err "Message #{msg} not implemented"
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

      # The running app directory.
      def msg_app
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
        return OS.host_cpu
      end

      # Get the platform Operating System
      def msg_platform_os
        return RUBY_PLATFORM
      end

      # Get the platform version
      def msg_platform_version
        return 'n/a'
      end

      # Is the platform Windows?
      def msg_platform_windows?
        return OS.windows?
      end

      # Is the platform Unix?
      def msg_platform_unix?
        return OS.posix?
      end

      # Is the platform Linux?
      def msg_platform_linux?
        return OS.posix?
      end

      # Is the platform Mac?
      def msg_platform_mac?
        return OS.mac?
      end

      # Is the platform WSL on Windows?
      def msg_platform_wsl?
        return self.class.wsl?
      end

      #
      # Is the platform WSL on Windows?
      #
      def self.wsl?
        return false unless OS.linux?

        ENV.key?('WSL_DISTRO_NAME') ||
          ENV.key?('WSL_INTEROP') ||
          File.read('/proc/sys/kernel/osrelease').downcase.include?('microsoft')
      rescue
        return false
      end

      #
      # Get the command to open a file on this platform.
      #
      def self.open_for_platform
        return 'open' if OS.mac?
        return 'xdg-open' if OS.posix?

        return 'Start-Process' if OS.windows?
        return 'explorer.exe' if self.wsl?

        return nil
      end

      # ---------------------------------------------------------------------
      #    Object Documentation
      # ---------------------------------------------------------------------

      #
      # Get the object's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'The gloo system objects are virtual objects — ' \
            "accessed like other objects (via 'gloo' or the shortcut " \
            '$), but their values are set by the system and cannot be ' \
            'updated. They also do not show up in the object heap. Some ' \
            'names include an underscore to separate words; a period ' \
            'can be used instead, so gloo.working_dir and ' \
            'gloo.working.dir are identical.',
          :children => [
            'app — Path of the running app (same as gloo_projects).',
            'hostname — Get the system hostname.',
            'user — Get the logged in user.',
            'line — A carriage return (line feed) character.',
            "user_home — Get the user's home directory.",
            'working_dir — Get the working directory.',
            'gloo_home — Get the gloo home directory.',
            'gloo_config — Get the gloo configuration directory.',
            'gloo_projects — Get the gloo projects directory.',
            'gloo_log — Get the gloo logging directory.',
            'screen_lines — Get the number of lines on screen.',
            'screen_cols — Get the number of columns on screen.',
            'platform_cpu — Get the platform CPU.',
            'platform_os — Get the platform operating system.',
            'platform_version — Get the platform version.',
            'platform_windows? — Is the platform Windows?',
            'platform_unix? — Is the platform Unix?',
            'platform_linux? — Is the platform Linux?',
            'platform_mac? — Is the platform Mac?'
          ],
          :examples => <<~EXAMPLES.strip
            > show gloo.user
            > show $.user

            > show gloo.working_dir
            > show gloo.working.dir
            > show $.working_dir
            > show $.working.dir
          EXAMPLES
        }
      end

    end
  end
end
