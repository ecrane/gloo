# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Data conversion manager.
#

module Gloo
  module Convert
    class Converter

      #
      # Initializer.
      #
      def initialize( engine )
        @engine = engine
      end

      # ---------------------------------------------------------------------
      #    Convert
      # ---------------------------------------------------------------------

      #
      # Convert the given value to the specified type,
      # or if no conversion is available, revert to default.
      #
      def convert( value, to_type, default = nil )
        begin
          name = "Gloo::Convert::#{value.class}To#{to_type}"
          clazz = name.split( '::' ).inject( Object ) { |o, c| o.const_get c }
          o = clazz.new
          return o.convert( value )
        rescue => e
          @engine.log_exception e
        end

        return default
      end

    end
  end
end
