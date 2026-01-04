# 
# A Base class for extensions.
# Used by extensions to register verbs and objects.
# 
module Gloo
  module Core
    class ExtBase

      # 
      # Register verbs and objects.
      # 
      def register( callback )
        raise NotImplementedError, "Extensions must implement register method"
      end

    end
  end
end
  