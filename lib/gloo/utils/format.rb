# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2020 Eric Crane.  All rights reserved.
#
# Formatting utilities
#

module Gloo
  module Utils
    class Format

      #
      # Format number, adding comma separators.
      # Ex: 1000 -> 1,000
      #
      def self.number( num )
        return num.to_s.reverse.scan( /.{1,3}/ ).join( ',' ).reverse
      end

    end
  end
end
