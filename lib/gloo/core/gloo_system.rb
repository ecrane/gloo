# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# The System Object.
# A virtual Object: the system object can be used to access
# system level variables and functions.  But it is not
# actually an object in the normal sense of the word.
#

module Gloo
  module Core
    class GlooSystem < Obj

      KEYWORD = 'gloo'.freeze
      KEYWORD_SHORT = '$'.freeze

      attr_reader :pn

      # Set up the object.
      def initialize( pn )
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
      def value_is_string?
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

        $log.error "Message #{msg} not implemented"
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
        return $settings.user_root
      end

      # Get the Gloo home directory
      def msg_gloo_config
        return $settings.config_path
      end

      # Get the Gloo projects directory
      def msg_gloo_projects
        return $settings.project_path
      end

      # Get the Gloo log directory
      def msg_gloo_log
        return $settings.log_path
      end

    end
  end
end
