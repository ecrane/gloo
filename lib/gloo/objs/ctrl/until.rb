# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# A looping construct...do something until a condition is true.
#

module Gloo
  module Objs
    class Until < Gloo::Core::Obj

      KEYWORD = 'until'.freeze
      KEYWORD_SHORT = 'until'.freeze
      DO = 'do'.freeze
      DONE = 'done'.freeze
      INDEX = 'index'.freeze
      MAX = 'max'.freeze
      NO_DONE_ERR = 'Could not run until loop %s: it has no done script.'.freeze
      MAX_ERR = "Could not finish until loop %s: done wasn't true after %s passes.".freeze

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
      # The most passes to run, or nil for no limit. A missing max, or
      # one that isn't a positive number, is no limit.
      #
      def max
        value = find_child_value( MAX )
        return nil unless value.is_a?( ::Integer ) && value.positive?

        return value
      end

      #
      # Set the index of the current pass, if there is an index child.
      #
      def set_index( index )
        o = find_child INDEX
        return unless o

        o.set_value index
      end

      #
      # Run the do script once. Returns true if a break loop in it
      # ended the run, so the loop should stop. A plain break ends only
      # the do script, and the loop goes on.
      #
      def run_do
        o = find_child DO
        return false unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
        return o.respond_to?( :broke_loop? ) && o.broke_loop?
      end

      #
      # Run the done script, and say whether the loop is done: its
      # result (in it) by the [bool] rule. Nil if anything in it
      # reported an error: the answer can't be known, so the loop stops.
      #
      def run_done( done )
        errors_before = @engine.run_error_count
        Gloo::Exec::Dispatch.message( @engine, 'run', done )
        return nil if @engine.run_error_count > errors_before

        return Gloo::Objs::Boolean.to_bool( @engine, @engine.heap.it.value )
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
      # Add children to this object: just the do and done scripts.
      # index and max are optional.
      #
      def add_default_children
        fac = @engine.factory
        fac.create_script DO, '', self
        fac.create_script DONE, '', self
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
      # Run the loop: do, then done, until done is true. Stops early on
      # break loop in do, or an error in done; with a max, reaching it
      # is an error.
      #
      def msg_run
        done = find_child DONE
        return fail_with( format( NO_DONE_ERR, pn ) ) if blank_script?( done )

        limit = max
        pass = 0
        loop do
          set_index pass
          return if run_do

          finished = run_done( done )
          # nil: done reported an error, already reported.
          return @engine.heap.it.set_to( false ) if finished.nil?
          return if finished

          pass += 1
          return fail_with( format( MAX_ERR, pn, limit ) ) if limit && pass >= limit
        end
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # Is the script missing, or without a line to run?
      #
      def blank_script?( script )
        return true if script.nil?

        lines = Array( script.value )
        return lines.all? { |line| line.to_s.strip.empty? }
      end

      #
      # Report that the loop couldn't run or finish; it is false.
      #
      def fail_with( msg )
        @engine.err msg
        @engine.heap.it.set_to false
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
          :description => 'Run a script again and again until a condition ' \
            'is true. Each pass runs do, then done; the loop ends when ' \
            "done's result is true. do always runs at least once.",
          :children => [
            'do (script) — The action to perform on each pass.',
            "done (script) — Required. Run after each pass; the loop ends when its result (it) is true. Usually one line: done [script] : eval ^^.x > 100. True and false follow the [bool] rule (see doc language_syntax, What Counts as True).",
            'index (integer) — Optional. The current pass, counting from 0.',
            'max (integer) — Optional. The most passes to run. Without it (or with 0) there is no limit, and a loop whose done never comes true runs until stopped.'
          ],
          :messages => [
            'run — Run the loop until done is true.'
          ],
          :errors => [
            "#{format( NO_DONE_ERR, '{path}' )} — There is no done script, or it is blank. Nothing runs, and it is false.",
            "#{format( MAX_ERR, '{path}', '{max}' )} — max passes ran and done never came true. it is false.",
            'Any error in done ends the loop: whether it is done can\'t be known. it is false. An error in do doesn\'t; the next pass may work.'
          ],
          :notes => 'break in do skips the rest of the pass; break loop ends the loop (see doc iterators, Skipping an Item or Ending a Loop). done is checked after each pass, so do always runs at least once.',
          :examples => <<~EXAMPLES.strip
            count [can] :
              x [int] : 0
              up [until] :
                do [script] : tell count.x to inc
                done [script] : eval count.x > 100
              on_load [script] :
                tell count.up to run
                show count.x

            retry [can] :
              tries [int] : 0
              pick [until] :
                max [int] : 5
                index [int] :
                do [script] : tell retry.tries to inc
                done [script] : eval retry.tries = 3
              on_load [script] :
                tell retry.pick to run
                show retry.pick.index
          EXAMPLES
        }
      end

    end
  end
end
