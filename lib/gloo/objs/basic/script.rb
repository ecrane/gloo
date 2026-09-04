# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# A Script.
# A set of commands to be run.
#

module Gloo
  module Objs
    class Script < Gloo::Core::Obj

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
      # Serialize this object's value for saving to a file.
      # A script's value is an Array of command lines (once add_line
      # has been called) or a single-line String. Render as indented
      # body lines below the declaration, gloo's convention for
      # scripts -- not a BEGIN/END block, which is reserved for a
      # literal multi-line string value.
      #
      def serialize_value( indent )
        lines = if value_is_array?
                  value
                elsif value_string? && !value.strip.empty?
                  [ value ]
                else
                  []
                end
        return ' :' if lines.empty?

        t = "\t" * ( indent + 1 )
        body = lines.map { |line| "#{t}#{line}" }.join( "\n" )
        return " :\n#{body}"
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
        s = Gloo::Exec::Script.new( @engine, self )
        s.run
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
          :description => 'An executable script — a set of commands to be run.',
          :messages => [
            'run — Run the script. The script can be run by telling the ' \
              'object to run, or via the run verb.'
          ],
          :examples => <<~EXAMPLES.strip
            script [can] :
              on_load [script] :
                show "Showing multiple lines..."
                show script.msg1
                show script.msg2
                show script.msg3
                show "Done."
              msg1 [string] : one
              msg2 [string] : two
              msg3 [string] : three
          EXAMPLES
        }
      end

    end
  end
end
