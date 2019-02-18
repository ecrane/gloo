# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# The Object Heap.
# The collection of objects that are currently in play in
# the running engine.
#

module OutlineScript
  module Core
    class Heap
      
      attr_reader :context, :it, :root
      
      # Set up the object heap.
      def initialize()
        $log.debug "object heap intialized..."
        
        @root = []
        @context = ObjRef.root
        @it = It.new
      end
      
      
    end
  end
end
