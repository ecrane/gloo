# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# A looping construct...do something x times.
#

module Gloo
  module Objs
    class Repeat < Gloo::Core::Obj

      KEYWORD = 'repeat'.freeze
      KEYWORD_SHORT = 'repeat'.freeze
      TIMES = 'times'.freeze
      INDEX = 'index'.freeze
      DO = 'do'.freeze

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
      # Get the URI from the child object.
      # Returns nil if there is none.
      #
      def times
        return find_child_value( TIMES ) || 0
      end

      #
      # Run the do script once.
      #
      def run_do
        o = find_child DO
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end

      #
      # Set the index of the current iteration.
      #
      def set_index( index )
        o = find_child INDEX
        return unless o

        o.set_value index
      end

      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      #
      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      #
      def add_children_on_create?
        return true
      end

      #
      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      #
      def add_default_children
        fac = @engine.factory
        fac.create_int TIMES, 0, self
        fac.create_int INDEX, 0, self
        fac.create_script DO, '', self
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
      # Run the repeat loop.
      #
      def msg_run
        times.times do |index|
          set_index index
          run_do
        end
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
          :description => 'Run a script a given number of times.',
          :children => [
            'times (integer) — Default: 0. The number of times to run the script.',
            'index (integer) — Default: 0. The current iteration when the repeat loop is running.',
            'do (script) — The action to perform for each iteration of the loop.'
          ],
          :messages => [
            'run — Run the script for the given number of times.'
          ],
          :examples => <<~EXAMPLES.strip
            repeat [can] :
              s [string] :
              on_load [script] :
                put $.screen_cols / 2 into repeat.x.times
                tell repeat.x to run
                show repeat.s
                tell repeat.y to run
                show repeat.s
              x [repeat] :
                times [integer] : 30
                index [integer] : 0
                do [script] : put repeat.s + '-' into repeat.s
              y [repeat] :
                times [integer] : 10
                index [integer] : 0
                do [script] : show repeat.y.index
          EXAMPLES
        }
      end

    end
  end
end
