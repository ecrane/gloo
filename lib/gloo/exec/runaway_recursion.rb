# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Scripts ran inside each other until Ruby ran out of stack: a script
# that runs itself (directly, or through others) with no end.
#
# It isn't a StandardError, on purpose: nothing on the way up may
# swallow it. It unwinds the run to the line that started the
# recursion, which reports it once (see Runner).
#

module Gloo
  module Exec
    class RunawayRecursion < Exception

      MSG = 'Could not run %s: scripts ran %d deep, one inside ' \
            'another (runaway recursion?).'.freeze

      attr_reader :location, :start_depth

      #
      # Note where it happened: the deepest script, how deep it was, and
      # the depth (count of running scripts) of the line that started
      # the recursion.
      #
      def initialize( script_pn, depth, location, start_depth = 0 )
        super( format( MSG, script_pn, depth ) )
        @location = location
        @start_depth = start_depth
      end

    end
  end
end
