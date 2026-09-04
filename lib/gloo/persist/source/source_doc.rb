# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# The concrete source model for one loaded file: an ordered list of
# nodes (comments, blank lines, directives, and object declarations)
# that mirrors what the loader actually read, so a save can rewrite
# the file instead of regenerating it from the heap.
#
# The top level plays the same role as an Source::ObjNode's children
# list -- there is no special "root" wrapper, just the file's own
# ordered content, which may include more than one top-level object
# declaration (a file may legitimately declare several roots).
#

module Gloo
  module Persist
    module Source
      class SourceDoc

        attr_reader :children

        #
        # Set up an empty source document.
        #
        def initialize
          @children = []
        end

        #
        # The top-level object declarations in this file (usually one,
        # per the "a file owns its declarations" model -- more than one
        # only when the file legitimately declares several roots).
        #
        def roots
          return @children.select { |n| n.is_a?( Source::ObjNode ) }
        end

      end
    end
  end
end
