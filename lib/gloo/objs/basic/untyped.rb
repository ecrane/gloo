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
          :description => 'An object with no type. A type declares ' \
            'which messages an object can receive; an untyped object ' \
            'receives only the base object messages (blank?, ' \
            'contains?, responds_to?, reload, unload) but can hold a ' \
            'value of any kind. If no type is specified when an object ' \
            'is created, it is untyped. Prefer untyped when you only ' \
            'need to hold, compare, or show a value and do not need ' \
            'type-specific behaviour.',
          :examples => <<~EXAMPLES.strip
            > create x
            > put 1 into x
            > put 'string' into x

            #
            # Declared with a bare colon, or with [any]:
            #
            slot :
            flag [any] :
          EXAMPLES
        }
      end

    end
  end
end
