# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# Nested container shorthand: a dotted name in a declaration
# (page.core.users.list [type] :) means "find or create a container
# for each prefix segment, then declare the real object under the
# last one". A segment that already names some other kind of object
# is used as-is, not forced to a container.
#

module Gloo
  module Persist
    class ShorthandExpander

      #
      # Set up an expander for the given engine.
      #
      def initialize( engine )
        @engine = engine
      end

      #
      # Split a possibly-dotted name against the given parent. Returns
      # [leaf_name, parent_for_the_leaf, roots_touched, created]:
      #  - roots_touched: containers created OR reused directly under
      #    the heap root, for the loader to register as this file's roots
      #  - created: containers this call actually created (any level),
      #    for the loader to remember as its own
      #
      def expand( name, parent )
        return [ name, parent, [], [] ] unless name.include?( '.' )

        segments = name.split( '.' )
        leaf = segments.pop
        roots = []
        created = []
        segments.each do |seg|
          child = parent.find_child( seg )
          unless child
            child = @engine.factory.create_can( seg, parent )
            created << child
          end
          roots << child if parent == @engine.heap.root
          parent = child
        end
        return [ leaf, parent, roots, created ]
      end

    end
  end
end
