# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# An HTML Element.
# Note that the object name is the tag!
# 
# An Element's content can be in a container of that nane,
# or it can be the simple value of the obj.  If there is no
# content child, the simple value will be used.
# 
# Attibutes is a container with all attributes of the tag.
# ID and CLASSES attributes can be called out more simply
# as children of the element obj.
#

module Gloo
  module Objs
    class Element < Gloo::Core::Obj

      KEYWORD = 'element'.freeze
      KEYWORD_SHORT = 'e'.freeze

      # Element
      ID = 'id'.freeze
      CLASSES = 'classes'.freeze
      ATTRIBUTES = 'attributes'.freeze
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
      # Return the array of attributes if there are any.
      # 
      def attributes_hash
        attr_can = find_child ATTRIBUTES

        if attr_can && attr_can.children.size > 0
          h = {}
          attr_can.children.each do |o|
            h[ o.name ] = o.value
          end
          return h
        end

        return {}
      end

      # 
      # Get all attributes of the tag.
      # 
      def tag_attributes
        attr_h = attributes_hash
        return nil unless attr_h && attr_h.size > 0

        attr_str = ''
        attr_h.each do |k,v|
          unless v.blank?
            attr_str << " #{k}=\"#{v}\"" 
          end
        end

        return attr_str
      end

      #
      # Get the tag.
      # This is the name, up until an '_' char.
      # Because name must be unique in the parent, and with HTML
      # we need a way to have multiple of the same tag at the
      # same level.
      #
      def tag
        i = self.name.index( '_' )        
        return i ? self.name[ 0..(i-1) ] : self.name
      end

      #
      # Get the opening tag.
      #
      def tag_open
        tag_attributes = self.tag_attributes
        if tag_attributes
          return "<#{tag}#{tag_attributes}>"
        else
          return "<#{tag}>"
        end
      end

      #
      # Get the closing tag.
      #
      def tag_close
        return "</#{tag}>"
      end

      # 
      # Get all the children elements of the content.
      # 
      def content_child
        return find_child CONTENT
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
        attr = fac.create_can ATTRIBUTES, self
        fac.create_string ID, '', attr
        fac.create_string CLASSES, '', attr

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
        content = self.render_html
        @engine.heap.it.set_to content 
        return content
      end


      # ---------------------------------------------------------------------
      #    Render
      # ---------------------------------------------------------------------

      # 
      # Render the element as HTML.
      # 
      def render_html
        content_text = render_content :render_html

        return "#{tag_open}#{content_text}#{tag_close}"
      end

      #
      # Render the element as text, without tags.
      # 
      def render_text
        content_text = render_content :render_text

        return "#{content_text}"
      end

      # 
      # Render the element content using the specified render function.
      # This is a recursive function (through one of the other render functions).
      # 
      def render_content render_ƒ
        obj = content_child
        obj = self if obj.nil?

        return Element.render_obj( obj, render_ƒ, @engine )
      end

      # 
      # Render an object which might be an element,
      # a container of items, or something else.
      # 
      def self.render_obj obj, render_ƒ, engine
        rendered_obj_content = ''
        return nil unless obj

        if obj.children.size > 0
          obj.children.each do |e|

            e = Gloo::Objs::Alias.resolve_alias( engine, e )
            if e.class == Element
              rendered_obj_content << e.send( render_ƒ )
            elsif e.class == Form
              rendered_obj_content << e.render
            elsif e
              data = render_thing e, render_ƒ, engine
              ( rendered_obj_content << data ) if data # e.render( render_ƒ )
            end
          end
        else
          rendered_obj_content << obj.value
        end

        return rendered_obj_content
      end

      def self.render_thing e, render_ƒ, engine
        begin
          return e.render( render_ƒ )
        rescue => e
          engine.log_exception e
          return ''
        end
      end
  
    end
  end
end
