# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Data conversion manager.
#

module Gloo
  module Convert
    class Converter

      # How each type reads in a warning: "'x' is not an integer".
      TYPE_NAMES = {
        'Integer' => 'an integer',
        'Decimal' => 'a decimal number',
        'Date' => 'a date',
        'Time' => 'a time',
        'DateTime' => 'a date and time'
      }.freeze
      NO_CONVERSION_ERR = 'There is no conversion to '.freeze

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
      # If the value isn't really of that type (eg. 'x' for an
      # integer), the conversion is still the best guess, and a warning
      # says what was guessed. A kind of value there's no converter for
      # is also warned about, using the default. Converting to a type
      # that isn't known is an error.
      #
      def convert( value, to_type, default = nil )
        begin
          name = "Gloo::Convert::#{value.class}To#{to_type}"
          clazz = find_converter( name )
          unless TYPE_NAMES.key?( to_type )
            @engine.err "#{NO_CONVERSION_ERR}'#{to_type}'."
            return default
          end
          unless clazz
            @engine.warn "'#{value}' is not #{TYPE_NAMES[ to_type ]}; " \
              "using #{default.nil? ? 'no value' : default}."
            return default
          end

          o = clazz.new
          result = o.convert( value )
          warn_bad_value( o, value, result, to_type )
          return result
        rescue => e
          @engine.log_exception e
        end

        return default
      end

      private

      #
      # Find the converter class by name, or nil if there isn't one for
      # that kind of value.
      #
      def find_converter( name )
        return name.split( '::' ).inject( Object ) { |o, c| o.const_get( c, false ) }
      rescue NameError
        return nil
      end

      #
      # Warn if the converter says the value isn't valid for its type.
      #
      def warn_bad_value( converter, value, result, to_type )
        return unless converter.respond_to?( :valid? )
        return if converter.valid?( value, result )

        @engine.warn "'#{value}' is not #{TYPE_NAMES[ to_type ]}; " \
          "using #{describe( converter, result )}."
      end

      #
      # Describe the guess for a warning.
      #
      def describe( converter, result )
        return 'no value' if result.nil?
        return converter.describe( result ) if converter.respond_to?( :describe )

        return result.to_s
      end

    end
  end
end
