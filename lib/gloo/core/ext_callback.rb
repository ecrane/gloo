# 
# A mechanism for registering extension components.
# 
module Gloo
  module Core
    class ExtCallback

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
      
    end
  end
end
  