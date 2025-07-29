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
      AUTOFOCUS = 'autofocus'.freeze
      COLS = 'cols'.freeze
      ROWS = 'rows'.freeze
      DESCRIPTION = 'description'.freeze
      CHECKED = 'checked'.freeze
      OPTIONS = 'options'.freeze
      
      # Style attributes
      FIELD_GROUP = 'field_group'.freeze
      FIELD_LABEL = 'field_label'.freeze
      FIELD_CONTROL = 'field_control'.freeze

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

        # If there is no child, use the obj's name
        return self.name unless o

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
      def field_value
        o = find_child VALUE
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
      end

      #
      # Get the value tag for the form field.
      #
      def value_tag
        value = field_value
        return "value='#{value}'" if value
        return ''
      end

      #
      # Get the label for the form field.
      #
      def label_value
        o = find_child LABEL

        # If there is no child, use the obj's name
        return self.name_value.capitalize unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
      end

      #
      # Get the label tag for the form field.
      #
      def label_tag
        label = label_value
        label_data = ''
        if label
          label_data = <<~HTML
            <label class="#{field_label_styles}" for="#{name_value}">
              #{label}
            </label>
          HTML
        end
        return label_data
      end

      #
      # Get the placeholder for the form field.
      #
      def placeholder_value
        o = find_child PLACEHOLDER
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
      end

      #
      # Get the placeholder tag for the form field.
      #
      def placeholder_tag
        placeholder = placeholder_value
        return "placeholder='#{placeholder}'" if placeholder
        return ''
      end

      # 
      # Should this field autofocus?
      # 
      def autofocus?
        o = find_child AUTOFOCUS
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return nil unless o
        return o.value
      end

      #
      # Get the autofocus tag for the form field.
      #
      def autofocus_tag
        return "autofocus='autofocus'" if autofocus?
        return ''
      end

      # 
      # Get the cols for the form field.
      # 
      def cols_value
        o = find_child COLS
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
      end

      #
      # Get the cols tag for the form field.
      #
      def cols_tag
        cols = cols_value
        return "col-#{cols}" if cols
        return ''
      end

      # 
      # Get the rows for the form field.
      # Only applies to textarea fields.
      # 
      def rows_value
        o = find_child ROWS
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
      end

      #
      # Get the rows tag for the form field.
      # Only applies to textarea fields.
      #
      def rows_tag
        rows = rows_value
        return "rows='#{rows}'" if rows
        return ''
      end

      #
      # Get the description for the form field.
      #
      def description_value
        o = find_child DESCRIPTION
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o ? o.value : nil
      end

      # 
      # Should this field be checked?
      # 
      def checked?
        o = find_child CHECKED
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return nil unless o
        return o.value
      end

      #
      # Get the checked tag for the form field.
      #
      def checked_tag
        return "checked='checked'" if checked?
        return ''
      end

      # 
      # Get options for the select list.
      # 
      def select_options
        o = find_child OPTIONS
        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return nil unless o

        selected_value = field_value

        options = ''
        o.children.each do |child|
          if selected_value == child.name || selected_value == child.value
            selected = 'selected="selected"'
          else
            selected = ''
          end
          options += <<~HTML
            <option value="#{child.name}" #{selected}>#{child.value}</option>
          HTML
        end
        return options
      end

      # 
      # Get the field group styles.
      # 
      def field_group_styles
        o = find_child FIELD_GROUP
        if o
          o = Gloo::Objs::Alias.resolve_alias( @engine, o )
          return o ? o.value : ''
        end
        
        return @styles[FIELD_GROUP] || ''
      end

      # 
      # Get the field label styles.
      # 
      def field_label_styles
        o = find_child FIELD_LABEL
        if o
          o = Gloo::Objs::Alias.resolve_alias( @engine, o )
          return o ? o.value : ''
        end
        
        return @styles[FIELD_LABEL] || ''
      end

      # 
      # Get the field control styles.
      # 
      def field_control_styles
        o = find_child FIELD_CONTROL
        if o
          o = Gloo::Objs::Alias.resolve_alias( @engine, o )
          return o ? o.value : ''
        end
        
        return @styles[FIELD_CONTROL] || ''
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
        fac.create_string TYPE, 'text', self
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
      # Render the form field.
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
      # Render the field, switch on type.
      def render styles = {}
        @styles = styles

        case type_value
        when 'text'
          return render_text
        when 'hidden'
          return render_hidden
        when 'textarea'
          return render_textarea
        when 'checkbox'
          return render_checkbox
        when 'search'
          return render_text
        when 'select'
          return render_select
        end
      end

      # 
      # Render the hidden field as HTML.
      # 
      def render_hidden
        return <<~HTML
          <input type="hidden" #{value_tag} name="#{name_value}" id="#{name_value}" />
        HTML
      end

      # 
      # Render the text field as HTML.
      # 
      def render_text
        return <<~HTML
          <div class="#{field_group_styles} #{cols_tag}">
            #{label_tag}
            <input #{placeholder_tag} #{autofocus_tag} #{rows_tag}
              class="#{field_control_styles}" 
              type="#{type_value}" #{value_tag}
              name="#{name_value}" id="#{name_value}" />
          </div>
        HTML
      end

      # 
      # Render the textarea field as HTML.
      # 
      def render_textarea
        return <<~HTML
          <div class="#{field_group_styles} #{cols_tag}">
            #{label_tag}
            <textarea #{placeholder_tag} #{autofocus_tag} #{rows_tag}
              class="#{field_control_styles}" 
              name="#{name_value}" id="#{name_value}">#{field_value}</textarea>
          </div>
        HTML
      end

      # 
      # Render the checkbox field as HTML.
      # 
      def render_checkbox
        return <<~HTML
          <div class="#{field_group_styles} #{cols_tag}">
            #{label_tag}
            <label class="checkbox #{field_control_styles}">
              <input type="checkbox" 
                #{checked_tag} value="true"
                name="#{name_value}" id="#{name_value}" />
                #{description_value}
            </label>
          </div>
        HTML
      end

      # 
      # Render the select field as HTML.
      # 
      def render_select
        return <<~HTML
          <div class="#{field_group_styles} #{cols_tag}">
            #{label_tag}
            <select class="#{field_control_styles}" 
              name="#{name_value}" id="#{name_value}">
              #{select_options}
            </select>
          </div>
        HTML
      end

    end
  end
end
