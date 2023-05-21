# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Mode the Application is running in.
#

module Gloo
  module App
    class Mode

      EMBED = :embed      # Run as embedded script processor
      CLI = :cli          # Run in interactive (CLI) mode
      SCRIPT = :script    # Run a script
      VERSION = :version  # Show version information
      HELP = :help        # Show the help screen
      TEST = :test        # Running in Unit Test mode.

      #
      # Get the default mode.
      #
      def self.default_mode
        return EMBED
      end

    end
  end
end
