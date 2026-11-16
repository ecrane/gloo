#
# A mechanism for registering extension components.
#
# Each library or extension registers through its own callback, which
# remembers what it registered, so the library can be unloaded later:
# its verbs and object types taken out of the dictionary again.
#
module Gloo
  module Plugin
    class Callback

      attr_reader :verbs, :objs

      #
      # Initialize the callback.
      #
      def initialize( engine )
        @engine = engine
        @verbs = []
        @objs = []
      end

      #
      # Register a verb.
      #
      def register_verb( verb_class )
        @engine.log.debug "Registering verb: #{verb_class} from callback helper"
        @verbs << verb_class
        @engine.dictionary.register_verb_post_start( verb_class, @engine )
      end

      #
      # Register an object.
      #
      def register_obj( object_class )
        @engine.log.debug "Registering object: #{object_class} from callback helper"
        @objs << object_class
        @engine.dictionary.register_obj_post_start( object_class, @engine )
      end

      #
      # Take everything this callback registered out of the dictionary.
      # The Ruby classes stay loaded (Ruby can't un-require), but gloo
      # decides what exists from the dictionary, so they're gone.
      #
      def unregister
        @verbs.each { |v| @engine.dictionary.unregister_verb( v ) }
        @objs.each { |o| @engine.dictionary.unregister_obj( o ) }
      end

      #
      # The objects on the heap whose type is one this callback
      # registered (or a subclass of one), in the order they're found.
      #
      def objects_in_use
        found = []
        each_obj( @engine.heap.root ) do |obj|
          found << obj if @objs.any? { |klass| obj.is_a?( klass ) }
        end
        return found
      end

      private

      #
      # Call the block with every object below the given one.
      #
      def each_obj( parent, &block )
        parent.children.each do |child|
          block.call( child )
          each_obj( child, &block )
        end
      end

    end
  end
end
