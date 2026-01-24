# 
# A mechanism for registering extension components.
# 
module Gloo
  module Plugin
    class Callback

      # 
      # Initialize the callback.
      # 
      def initialize( engine )
        @engine = engine
      end

      # 
      # Register a verb.
      # 
      def register_verb( verb_class )
        @engine.log.debug "Registering verb: #{verb_class} from callbackup helper"
        @engine.dictionary.register_verb_post_start( verb_class )
      end

      # 
      # Register an object.
      # 
      def register_obj( object_class )
        @engine.log.debug "Registering object: #{object_class} from callback helper"
        @engine.dictionary.register_obj_post_start( object_class )
      end
      
    end
  end
end