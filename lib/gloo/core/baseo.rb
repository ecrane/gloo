# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An abstract base object.
# All objects and verbs derive from this.
#

module Gloo
  module Core
    class Baseo

      attr_accessor :name

      NOT_IMPLEMENTED_ERR = 'Not implemented yet!'.freeze

      # Set up the object.
      def initialize
        @name = ''
      end

      #
      # The object type, suitable for display.
      #
      def type_display
        raise 'this method should be overriden'
      end

    end
  end
end
