# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A web page hosted in a gloo web server.
#

module Gloo
  module Objs
    class Page < Gloo::Core::Obj

      KEYWORD = 'page'.freeze
      KEYWORD_SHORT = 'page'.freeze

      # Page Title
      TITLE = 'title'.freeze

      # Events
      ON_RENDER = 'on_render'.freeze
      ON_RENDERED = 'on_rendered'.freeze

      # Parameters used during render.
      PARAMS = 'params'.freeze

      # Content
      HEAD = 'head'.freeze
      BODY = 'body'.freeze


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
      # Get the title from the child object.
      # Returns nil if there is none.
      #
      def title_value
        title = find_child TITLE
        return title ? title.value : nil
      end

      #
      # Get the body obj.
      #
      def body
        return find_child BODY
      end


      #
      # Get the params hash from the child object.
      # Returns nil if there is none.
      #
      def params_hash
        {
          msg: 'Coming soon...'
        }
        params_can = find_child PARAMS
        return nil unless params_can

        h = {}
        params_can.children.each do |o|
          h[ o.name ] = o.value
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
        fac.create_string TITLE, '', self

        fac.create_script ON_RENDER, '', self
        fac.create_script ON_RENDERED, '', self

        fac.create_can PARAMS, self
        fac.create_can HEAD, self
        fac.create_can BODY, self
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
      # wrap the content in the tag with id and class.
      # 
      def wrap( tag, content, id=nil, classes=nil )
        return "<#{tag}>#{content}</#{tag}>"
      end

      # 
      # Render the page.
      # 
      def render
        title = wrap 'title', title_value
        h1 = wrap 'h1', title_value

        head = wrap 'head', title
        body_content = body.render

        # render params
        params_h = params_hash 
        if params_h
          renderer = ERB.new( body_content )
          body_content =  renderer.result_with_hash( params_h )
        end

        contents = wrap 'html', head + body_content
        return contents
      end

    end
  end
end
