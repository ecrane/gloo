# 
# A Base class for extensions.
# Used by extensions to register verbs and objects.
# 
module Gloo
  module Plugin
    class Base

      # 
      # Register verbs and objects.
      # 
      def register( callback )
        raise NotImplementedError, "Extensions must implement register method"
      end

    end
  end
end
  