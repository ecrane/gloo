# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An Untyped Object.
#

module Gloo
  module Objs
    class Untyped < Gloo::Core::Obj

      KEYWORD = 'untyped'.freeze
      KEYWORD_SHORT = 'any'.freeze

      #
      # The name of the object type.
      #
      def self.typename
        return KEYWORD
      end

      #
      # The short name of the object type.
      #
      def self.short_typename
        return KEYWORD_SHORT
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super
      end

      # ---------------------------------------------------------------------
      #    Object Documentation
      # ---------------------------------------------------------------------

      #
      # Get the object's documentation data.
      #
      def self.doc_data
        {
          :name => KEYWORD,
          :shortcut => KEYWORD_SHORT,
          :description => 'An untyped object. If no type is specified ' \
            'when an object is created it will be of this type.',
          :examples => <<~EXAMPLES.strip
            > create x
            > put 1 into x
            > put 'string' into x
          EXAMPLES
        }
      end

    end
  end
end
