# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2025 Eric Crane.  All rights reserved.
#
# An HTML Form Field.
#
# A Form Field is the definition of a form field, including label, type, etc.
#

module Gloo
  module Objs
    class Field < Gloo::Core::Obj

      KEYWORD = 'field'.freeze
      KEYWORD_SHORT = 'field'.freeze

      # Form
      NAME = 'name'.freeze
      ID = 'id'.freeze
      TYPE = 'type'.freeze
      VALUE = 'value'.freeze
      LABEL = 'label'.freeze
      PLACEHOLDER = 'placeholder'.freeze

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
      # Get the name for the form field.
      # 
      def name_value
        o = find_child NAME
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
      end

      #
      # Get the type for the form field.
      # For example, 'text', 'password', 'checkbox', etc.
      #
      def type_value
        o = find_child TYPE
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
      end

      #
      # Get the value for the form field.
      #
      def value_value
        o = find_child VALUE
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
      end

      #
      # Get the label for the form field.
      #
      def label_value
        o = find_child LABEL
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
      end

      #
      # Get the placeholder for the form field.
      #
      def placeholder_value
        o = find_child PLACEHOLDER
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
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

        # Create attributes with ID and Classes
        fac.create_string NAME, '', self
        fac.create_string METHOD, 'post', self
        fac.create_string ACTION, '', self
        fac.create_string CANCEL_PATH, '', self

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
        content = self.render
        @engine.heap.it.set_to content 
        return content
      end


      # ---------------------------------------------------------------------
      #    Render
      # ---------------------------------------------------------------------

      # 
      # Render the Form as HTML.
      # 
      def render
        name = name_value
        label = label_value
        label_data = ""
        if label
          label_data = <<-HTML
            <label class="control-label mb-1" for="#{name}">
              #{label}
            </label>
          HTML
        end
        return <<-HTML
          <div class="form-group col-12 mt-3">
            #{label_data}
            <input 
              placeholder="#{placeholder_value}" 
              class="form-control gloo-form-field" 
              autofocus="autofocus" 
              type="#{type_value}" 
              name="#{name}" 
              id="#{name}" />
          </div>
        HTML
      end

    end
  end
end
