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
        return "<#{tag}>"
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
      def content_elements
        content = find_child CONTENT
        return content ? content.children : nil
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
        fac.create_string ID, '', self
        fac.create_string CLASSES, '', self
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
      # Render the page as HTML.
      # 
      def render_html
        content_text = ''
        
        elements = content_elements
        if elements
          elements.each do |e|
            e = Gloo::Objs::Alias.resolve_alias( @engine, e )
            if e.class == Element
              content_text << e.render_html
            elsif e.class == Partial
              content_text << e.render_html
            else
              content_text << e.value.to_s
            end
          end
        else
          content_text << self.value
        end

        return "#{tag_open}#{content_text}#{tag_close}"
      end

      #
      # Render the page as text, without tags.
      # 
      def render_text
        content_text = ''
        
        elements = content_elements
        if elements
          elements.each do |e|
            e = Gloo::Objs::Alias.resolve_alias( @engine, e )
            if e.class == Element
              content_text << e.render
            elsif e.class == Partial
              content_text << e.render
            else
              content_text << e.value.to_s
            end
          end
        else
          content_text << self.value
        end

        return "#{content_text}"
      end
                    
    end
  end
end
