# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Scripts ran inside each other until Ruby ran out of stack: a script
# that runs itself (directly, or through others) with no end.
#
# It isn't a StandardError, on purpose: nothing on the way up may
# swallow it. It unwinds the whole run to the outermost verb, which
# reports it once (see Runner).
#

module Gloo
  module Exec
    class RunawayRecursion < Exception

      MSG = 'Could not run %s: scripts ran %d deep, one inside ' \
            'another (runaway recursion?).'.freeze

      attr_reader :location

      #
      # Note where it happened: the deepest script and how deep it was.
      #
      def initialize( script_pn, depth, location )
        super( format( MSG, script_pn, depth ) )
        @location = location
      end

    end
  end
end
