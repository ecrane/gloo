# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# The Runner is a static helper function.
# It is used to send the run command to verbs.
#

module Gloo
  module Exec
    class Runner

      #
      # Dispatch run command to a verb.
      # We abstract this out in case there are things
      # that need to be done before or after a verb
      # is done running.
      #
      def self.go( engine, verb )
        engine.log.debug "running verb #{verb.type_display}"
        engine.heap.error.start_tracking
        engine.exec_env.verbs.push verb
        begin
          verb&.check_syntax
          verb&.run
        rescue StandardError, ScriptError => ex
          # ScriptError (a SyntaxError from eval'd code, a LoadError
          # from a missing gem) isn't a StandardError, and would
          # otherwise stop gloo altogether.
          engine.handle_exception( ex )
        rescue SystemStackError
          runaway( engine, runaway_recursion( engine ) )
        rescue Gloo::Exec::RunawayRecursion => ex
          runaway( engine, ex )
        ensure
          engine.exec_env.verbs.pop
        end
        engine.heap.error.clear_if_no_errors
      end

      #
      # Ruby ran out of stack: scripts ran inside each other with no
      # end. Note the deepest script, how deep, and where the recursion
      # started.
      #
      def self.runaway_recursion( engine )
        env = engine.exec_env
        pn = env.running_script&.obj&.pn
        return Gloo::Exec::RunawayRecursion.new(
          pn, env.scripts.size, env.current_location, recursion_start( env ) )
      end

      #
      # The depth of the line that started the recursion: the number of
      # scripts running below the first script that runs again further
      # up the stack. 0 (the outermost line) if none repeats.
      #
      def self.recursion_start( env )
        objs = env.scripts.stack.map( &:obj )
        counts = objs.tally
        return objs.index { |o| counts[ o ] > 1 } || 0
      end

      #
      # Runaway recursion unwinds the run to the line that started it,
      # and is reported there, once; that line is abandoned like any
      # failed line, and its script carries on. Every verb inside passes
      # it on. The outermost verb reports it in any case.
      #
      def self.runaway( engine, ex )
        env = engine.exec_env
        raise ex unless env.scripts.size <= ex.start_depth || env.verbs.size == 1

        engine.err ex.message, location: ex.location
        engine.heap.it.set_to false
      end

      #
      # Send 'run' message to the object.
      # Resolve the path_name and then send the run message.
      #
      def self.run( engine, path_name )
        engine.log.debug "running script at #{path_name}"
        pn = Gloo::Core::Pn.new( engine, path_name )
        return if pn.it_target_err?( 'run' )

        o = pn.resolve

        if o
          o.send_message 'run'
        else
          # The message never ran, so there is no result.
          engine.err Gloo::Core::NotFound.object( path_name )
          engine.heap.it.set_to false
        end
      end

    end
  end
end
