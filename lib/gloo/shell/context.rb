# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# A shell context.  Data associated with a running shell session.
# Ported from gloo-cli's ShellContext, namespace only.
#

module Gloo
  module Shell
    class Context

      attr_accessor :done

      #
      # Initialize the shell context.
      #
      def initialize
        @done = false
        @properties = {}
      end

      #
      # Get a property value.
      # Returns an empty array if the property doesn't exist.
      #
      def get( key )
        key = key.to_sym
        return @properties[ key ] if @properties.key?( key )

        return []
      end

      #
      # Set a property value.
      #
      def set( key, value )
        @properties[ key.to_sym ] = value
      end

      #
      # Add an item to a property list.
      #
      def add_to_list( key, item )
        key = key.to_sym
        list = get( key )
        list = [] unless list.is_a?( Array )

        list << item
        set( key, list )

        return list
      end

      #
      # Check if a property exists.
      #
      def has?( key )
        return @properties.key?( key.to_sym )
      end

      #
      # Get all property keys.
      #
      def keys
        return @properties.keys
      end

      #
      # Dynamic method access to properties.
      # e.g. context.verbs is the same as context.get(:verbs),
      # context.verbs = [...] is the same as context.set(:verbs, [...]).
      #
      def method_missing( method_name, *args, &block )
        if method_name.to_s.end_with?( '=' )
          key = method_name.to_s.chomp( '=' ).to_sym
          set( key, args.first )
        else
          key = method_name.to_sym
          get( key )
        end
      end

      #
      # Respond to missing methods for property access.
      #
      def respond_to_missing?( method_name, include_private = false )
        key = method_name.to_s.chomp( '=' ).to_sym
        return has?( key ) || super
      end

    end
  end
end
