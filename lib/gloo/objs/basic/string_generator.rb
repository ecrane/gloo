# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# String generation utilities.
# This is a static class.
#

module Gloo
  module Objs
    class StringGenerator

      # TO DO: Consider adding in Faker generators as well.


      # ---------------------------------------------------------------------
      #    Generators
      # ---------------------------------------------------------------------

      #
      # Generate a new UUID.
      #
      def self.uuid
        return SecureRandom.uuid
      end

      #
      # Generate a random alphanumeric string.
      #
      def self.alphanumeric len=10
        return SecureRandom.alphanumeric( len )
      end

      #
      # Generate a random hex string.
      #
      def self.hex len=10
        s = SecureRandom.hex( len )
      end

      #
      # Generate a random base64 string.
      #
      def self.base64 len=12
        return SecureRandom.base64( len )
      end

    end
  end
end
