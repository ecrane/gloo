# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A partial page.
#

module Gloo
  module Objs
    class Partial < Gloo::Core::Obj

      KEYWORD = 'partial'.freeze
      KEYWORD_SHORT = 'part'.freeze

      # Events
      ON_RENDER = 'on_render'.freeze
      ON_RENDERED = 'on_rendered'.freeze

      # Parameters used during render.
      PARAMS = 'params'.freeze

      # Content
      CONTENT = 'content'.freeze


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
      # Set the value with any necessary type conversions.
      #
      def set_value( new_value )
        self.value = new_value.to_s
      end

      #
      # Does this object support multi-line values?
      # Initially only true for scripts.
      #
      def multiline_value?
        return false
      end

      #
      # Get the content obj.
      #
      def content
        return find_child CONTENT
      end

      #
      # Get the params hash from the child object.
      # Returns nil if there is none.
      #
      def params_hash
        params_can = find_child PARAMS
        return nil unless params_can

        h = {}
        params_can.children.each do |o|
          h[ o.name ] = o.value
        end

        return h
      end


      # ---------------------------------------------------------------------
      #    Events
      # ---------------------------------------------------------------------

      #
      # Run the on render script if there is one.
      #
      def run_on_render
        o = find_child ON_RENDER
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end

      #
      # Run the on rendered script if there is one.
      #
      def run_on_rendered
        o = find_child ON_RENDERED
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
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

        fac.create_script ON_RENDER, '', self
        fac.create_script ON_RENDERED, '', self

        fac.create_can PARAMS, self
        fac.create_can CONTENT, self
      end


      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'render' ]
      end

      #
      # Get the expiration date for the certificate.
      #
      def msg_render
        part_content = self.render
        @engine.heap.it.set_to part_content 
        return part_content
      end

      # ---------------------------------------------------------------------
      #    Render
      # ---------------------------------------------------------------------

      # 
      # Render the page.
      # Use the specified render function or HTML by default.
      # 
      def render( render_ƒ = :render_html )
        run_on_render

        part_content = ''
        content.children.each do |e|
          part_content << e.send( render_ƒ )
        end
      
        part_content = Page.render_params part_content, params_hash

        run_on_rendered
        return part_content
      end

      # 
      # Render the layout with the body and head params.
      # 
      def render_layout( head, body )
        run_on_render

        part_content = ''
        content.children.each do |e|
          # part_content << e.render_html
          part_content << e.value.to_s
        end
      
        params = params_hash || {}
        params[ 'head' ] = head
        params[ 'body' ] = body

        part_content = Page.render_params part_content, params

        run_on_rendered
        return part_content
      end

    end
  end
end
