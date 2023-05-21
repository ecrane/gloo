# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Utility used to find objects.
#

module Gloo
  module Core
    class ObjFinder

      #
      # Find all objects in the given container that have
      # the given name.
      # If the container isn't provided, root will be used.
      #
      def self.by_name( engine, name, container = nil )
        container = engine.heap.root if container.nil?
        arr = []

        container.children.each do |o|
          arr << o if o.name == name
          arr += by_name( engine, name, o ) if o.child_count.positive?
        end

        return arr
      end

    end
  end
end
