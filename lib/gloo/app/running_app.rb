# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# The running application object within gloo.
# It is set and accessed from the engine.
# There can ever only be one runnign app within the instance of gloo.
#

module Gloo
  module App
    class RunningApp

      attr_reader :obj

      #
      # Set up the running app for the given object.
      #
      def initialize( obj, engine )
        @engine = engine
        @log = @engine.log
        @obj = obj
      end

      # 
      # Start the running app.
      def start
        obj.start
        @log.debug "running app started for #{@obj.pn}"
      end

      #
      # The running app has been stopped.
      #
      def stop
        obj.stop
        @log.debug "running app stopped for #{@obj.pn}"
      end

    end
  end
end