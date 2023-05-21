# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Data conversion manager.
#

module GlooLang
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
          name = "GlooLang::Convert::#{value.class}To#{to_type}"
          clazz = name.split( '::' ).inject( Object ) { |o, c| o.const_get c }
          o = clazz.new
          return o.convert( value )
        rescue => e
          @engine.log.error e.message
          @engine.heap.error.set_to e.message
        end

        return default
      end

    end
  end
end
