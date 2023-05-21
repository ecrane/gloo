# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A Script.
# A set of commands to be run.
#

module Gloo
  module Objs
    class Script < GlooLang::Core::Obj

      KEYWORD = 'script'.freeze
      KEYWORD_SHORT = 'cmd'.freeze

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
      # Set the value with any necessary type conversions.
      #
      def set_value( new_value )
        self.value = new_value.to_s
      end

      #
      # Set the value as an array.
      #
      def set_array_value( arr )
        self.value = arr
      end

      #
      # Add a line (cmd) to the script.
      #
      def add_line( line )
        if self.value_string?
          first = self.value
          self.set_array_value []
          self.value << first unless first.empty?
        elsif self.value_is_blank?
          self.set_array_value []
        end
        self.value << line.strip
      end

      #
      # Does this object support multi-line values?
      # Initially only true for scripts.
      #
      def multiline_value?
        return true
      end

      #
      # Get the number of lines in this script.
      #
      def line_count
        return self.value.count if self.value_is_array?

        if self.value_string?
          return self.value.strip.empty? ? 0 : 1
        end

        return 0
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'run' ]
      end

      #
      # Send the object the unload message.
      #
      def msg_run
        s = GlooLang::Exec::Script.new( @engine, self )
        s.run
      end

    end
  end
end
