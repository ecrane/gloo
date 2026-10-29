# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# Break out of the script without error.
#

module Gloo
  module Verbs
    class Break < Gloo::Core::Verb

      KEYWORD = 'break'.freeze
      KEYWORD_SHORT = 'stop'.freeze
      LOOP = 'loop'.freeze
      NOT_IN_A_LOOP = 'Could not break loop: not in a loop.'.freeze

      #
      # Run the verb.
      # Stop the execution of the current script. With loop (break
      # loop), also end the loop whose do script this is.
      #
      def run
        words = extra_words.split( ' ' )
        if words.first&.downcase == LOOP
          warn_words_after_loop( words.drop( 1 ) )
          break_loop
        else
          warn_unknown_words
          @engine.exec_env.running_script.break_out
        end
      end

      #
      # Get the Verb's keyword.
      #
      def self.keyword
        return KEYWORD
      end

      #
      # Get the Verb's keyword shortcut.
      #
      def self.keyword_shortcut
        return KEYWORD_SHORT
      end

      # ---------------------------------------------------------------------
      #    Private functions
      # ---------------------------------------------------------------------

      private

      #
      # End the running script and its loop. Only valid directly in a
      # loop's do script; anywhere else (a script the do runs, a group
      # script, outside any loop) it's an error and nothing stops.
      #
      def break_loop
        script = @engine.exec_env.running_script
        unless loop_do?( script&.obj )
          @engine.err NOT_IN_A_LOOP
          return
        end

        script.break_out( loop: true )
      end

      #
      # Is the object the do script of a loop (a repeat or an each)?
      #
      def loop_do?( obj )
        parent = obj&.parent
        return false unless parent.is_a?( Gloo::Objs::Repeat ) ||
                            parent.is_a?( Gloo::Objs::Each )

        return parent.find_child( Gloo::Objs::Each::DO ).equal?( obj )
      end

      #
      # Warn about anything written after break other than loop.
      # The break still happens.
      #
      def warn_unknown_words
        extra = extra_words
        return if extra.empty?

        @engine.warn "#{written_verb} takes only '#{LOOP}'; ignoring '#{extra}'."
      end

      #
      # Warn about anything written after break loop. The loop still
      # ends.
      #
      def warn_words_after_loop( words )
        return if words.empty?

        @engine.warn "#{written_verb} #{LOOP} takes no object; " \
                     "ignoring '#{words.join( ' ' )}'."
      end

      # ---------------------------------------------------------------------
      #    Verb Documentation
      # ---------------------------------------------------------------------

      #
      # Get the verb's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'Break out of the current script, stop running. ' \
            'In a loop\'s do script, break skips the rest of that pass ' \
            'and the loop goes on; break loop ends the whole loop.',
          :syntax => [ 'break', 'break loop' ],
          :parameters => [
            'loop — Optional. Also end the loop whose do script this is. ' \
            'Only valid directly in a loop\'s do script (repeat, or any ' \
            'kind of each).'
          ],
          :result => 'No more commands are executed in the currently ' \
            'running script. If there are other scripts in the stack, ' \
            'they will resume normally. In a loop\'s do script, a plain ' \
            'break ends that pass and the loop goes on with the next ' \
            'item. With break loop, the loop ends too and the script ' \
            'that ran it carries on.',
          :errors => [
            "#{NOT_IN_A_LOOP} — break loop in a script that isn't a " \
            'loop\'s do script: one the do script runs (with run, or a ' \
            'function), a loop\'s on_group_start or on_group_end, or a ' \
            'script outside any loop. Nothing stops.'
          ],
          :examples => <<~EXAMPLES.strip
            #
            # Break out of a script.
            #
            break_out [can] :
              x [bool] : false
              on_load [script] :
                if ^.x then break
                show 'should see this'
                put true into ^.x
                if ^.x then break
                show 'should not see this'

            #
            # In a loop: break skips an item, break loop ends the loop.
            # Shows 0, 1, 3, then 0, 1.
            #
            loops [can] :
              on_load [script] :
                tell loops.skip to run
                tell loops.early to run
              skip [repeat] :
                times [int] : 4
                index [int] :
                do [script] :
                  if loops.skip.index = 2 then break
                  show loops.skip.index
              early [repeat] :
                times [int] : 4
                index [int] :
                do [script] :
                  if loops.early.index = 2 then break loop
                  show loops.early.index
          EXAMPLES
        }
      end

    end
  end
end
