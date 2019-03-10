# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An Expression that can be evaluated.
#

module OutlineScript
  module Expr
    class LInteger < OutlineScript::Core::Literal
            
      # Is the given token an integer?
      def self.is_integer? token
        return true if token.is_a? Integer
        s = token.strip
        return s.to_i.to_s == s
      end
      
      # Set the value, converting to an integer.
      def set_value value
        @value = value.to_i
      end

      def to_s
        return self.value.to_s
      end

    end
  end
end
