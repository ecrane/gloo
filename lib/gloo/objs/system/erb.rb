# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object that evaluates an ERB template.
#
require 'erb'

module Gloo
  module Objs
    class Erb < Gloo::Core::Obj

      KEYWORD = 'erb'.freeze
      KEYWORD_SHORT = 'erb'.freeze
      TEMPLATE = 'template'.freeze
      PARAMS = 'params'.freeze
      RESULT = 'result'.freeze

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

      #
      # Get the ERB template.
      #
      def template_value
        return find_child_value TEMPLATE
      end

      #
      # Set the result of the ERB template conversion.
      #
      def set_result( data )
        r = find_child_resolve_alias RESULT
        return unless r

        r.set_value data
      end

      #
      # Get a hash with parameters for the ERB render.
      #
      def param_hash
        h = {}

        body = find_child PARAMS
        body.children.each do |child|
          child = Gloo::Objs::Alias.resolve_alias( @engine, child )
          h[ child.name ] = child.value
        end

        return h
      end

      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      #
      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      #
      def add_children_on_create?
        return true
      end

      #
      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      #
      def add_default_children
        fac = @engine.factory
        fac.create_text TEMPLATE, '', self
        fac.create_can PARAMS, self
        fac.create_text RESULT, '', self
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'run' ]
      end

      #
      # Run the ERB template conversion.
      #
      def msg_run
        tmpl = template_value
        return unless tmpl

        render = ERB.new( tmpl )
        set_result render.result_with_hash( param_hash )
      end

    end
  end
end
