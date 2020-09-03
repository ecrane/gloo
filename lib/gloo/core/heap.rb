# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# The Object Heap.
# The collection of objects that are currently in play in
# the running engine.
#

module Gloo
  module Core
    class Heap

      # The context is a reference to an object, usually a container.
      # The context will be the root by default.
      attr_reader :context

      attr_reader :it, :root, :error

      #
      # Set up the object heap.
      #
      def initialize
        $log.debug 'object heap intialized...'

        @root = Gloo::Objs::Container.new
        @root.name = 'root'

        @context = Pn.root
        @it = It.new
        @error = Error.new
      end

      #
      # Unload the given obj--remove it from the heap.
      #
      def unload( obj )
        can = obj.parent.nil? ? @root : obj.parent
        return unless can

        can.remove_child obj
      end

    end
  end
end
