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
          verb&.run
        rescue => ex
          engine.handle_exception( ex )
        ensure
          engine.exec_env.verbs.pop
        end
        engine.heap.error.clear_if_no_errors
      end

      #
      # Send 'run' message to the object.
      # Resolve the path_name and then send the run message.
      #
      def self.run( engine, path_name )
        engine.log.debug "running script at #{path_name}"
        pn = Gloo::Core::Pn.new( engine, path_name )
        o = pn.resolve

        if o
          o.send_message 'run'
        else
          engine.err "Could not send message to object.  Bad path: #{path_name}"
        end
      end

    end
  end
end
