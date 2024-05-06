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

      # Events
      ON_RENDER = 'on_render'.freeze
      ON_RENDERED = 'on_rendered'.freeze

      # Parameters used during render.
      PARAMS = 'params'.freeze

      # Content
      HEAD = 'head'.freeze
      BODY = 'body'.freeze
      CONTENT = 'content'.freeze
      TITLE = 'title'.freeze

      # Layout for this page.
      # If not specified, use the layout for the app.
      LAYOUT = 'layout'.freeze

      # Return Content type and HTML Code
      CONTENT_TYPE = 'content_type'.freeze
      HTML_CONTENT = 'html'.freeze
      TEXT_CONTENT = 'text'.freeze
      JSON_CONTENT = 'json'.freeze
      RETURN_CODE = 'return_code'.freeze

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
      # Get the head element.
      #
      def head
        return find_child HEAD
      end

      # 
      # Get the header content.
      # This might be in a content child, or it might be 
      # the head object itself.
      # 
      def head_content
        head_obj = head
        return nil unless head_obj

        content_obj = head_obj.find_child CONTENT
        return content_obj ? content_obj : head_obj
      end

      #
      # Get the body element.
      #
      def body
        return find_child BODY
      end

      # 
      # Get the body content.
      # This might be in a content child, or it might be 
      # the body object itself.
      # 
      def body_content
        body_obj = body
        return nil unless body_obj

        content_obj = body_obj.find_child CONTENT
        return content_obj ? content_obj : body_obj
      end

      #
      # Get the params hash from the child object.
      # Returns nil if there is none.
      #
      def params_hash
        params_can = find_child PARAMS
        return nil unless params_can

        if @request
          url_params = @request.query_params
          url_params.each do |k,v|
            o = params_can.find_child k
            o.set_value( v ) if o
          end
        end

        h = {}
        params_can.children.each do |o|
          h[ o.name ] = o.value
        end

        return h
      end

      # 
      # Get the return code.
      # SUCCESS is the default if none is set.
      # 
      def return_code
        code = find_child RETURN_CODE
        return code ? code.value : Gloo::WebSvr::ResponseCode::SUCCESS
      end

      # 
      # Get the content type.
      # 
      def content_type
        type = find_child CONTENT_TYPE
        return type ? type.value : nil
      end

      # 
      # Get the layout for this page.
      # 
      def page_layout
        o = find_child LAYOUT
        return nil unless o

        o = Gloo::Objs::Alias.resolve_alias( @engine, o )
        return o
      end

      # 
      # Is the return type HTML?
      # 
      def is_html?
        return true if content_type.nil?
        return content_type == HTML_CONTENT
      end

      # 
      # Is the return type TEXT?
      # 
      def is_text?
        return content_type == TEXT_CONTENT
      end

      # 
      # Is the return type JSON?
      # 
      def is_json?
        return content_type == JSON_CONTENT
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

        params = { :name => HEAD,
          :type => Gloo::Objs::Element.typename,
          :value => nil,
          :parent => self }
        head = fac.create params
        content = fac.create_can CONTENT, head
        params = { :name => TITLE,
          :type => Gloo::Objs::Element.typename,
          :value => nil,
          :parent => content }
        title = fac.create params

        params = { :name => BODY,
          :type => Gloo::Objs::Element.typename,
          :value => nil,
          :parent => self }
        body = fac.create params
        content = fac.create_can CONTENT, body
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
      # Wrap the content in the tag with id and class.
      # 
      def wrap( tag, content, id=nil, classes=nil )
        return "<#{tag}>#{content}</#{tag}>"
      end

      # 
      # Is there a redirect page set in the running app?
      # 
      def redirect_set?
        return false unless @engine.app_running?
        return @engine.running_app.obj.redirect
      end

      # 
      # Render the page.
      # If this is being called from the web server,
      # the request will be passed in and will include
      # request context such as params.
      # 
      def render request=nil
        @request = request
        run_on_render
        return nil if redirect_set?

        params = params_hash

        if is_html?
          contents = render_html params
        elsif is_json?
          contents = render_json
        elsif is_text?
          contents = render_text params
        else
          @engine.log.error "Unknown content type: #{content_type}"
          return nil
        end
        
        run_on_rendered
        @request = nil
        return nil if redirect_set?

        return contents
      end

      # 
      # Render the page as HTML.
      # 
      def render_html params
        head_obj = render_with_params head_content, :render_html, params
        body_obj = render_with_params body_content, :render_html, params

        layout = page_layout_or_app_layout
        if layout
          @engine.log.debug "Using Page Layout: #{layout.pn}"
          contents = layout.render_layout( head_obj, body_obj )
        else
          @engine.log.debug "No layout for page."
          contents = wrap( 'html', head_obj + body_obj )
        end

        return Gloo::WebSvr::Response.html_response( 
          @engine, contents, return_code )
      end

      # 
      # Get the layout for this page or if none for the app.
      # 
      def page_layout_or_app_layout
        layout = page_layout
        return layout if layout

        return nil unless @engine.app_running?
        return @engine.running_app.obj.default_page_layout
      end

      # 
      # Render the page as JSON.
      # 
      def render_json
        json_content = Gloo::Objs::Json.convert_obj_to_json( body )

        return Gloo::WebSvr::Response.json_response( @engine, json_content, return_code )
      end

      # 
      # Render the page as TEXT.
      # 
      def render_text params
        text_content = render_with_params body_content, :render_text, params
        return Gloo::WebSvr::Response.text_response( @engine, text_content, return_code )
      end

      # 
      # Given an object and a render message, render the object.
      # If the obj is nil, return an empty string.
      # If the params are nil, no param rendering is done.
      # 
      def render_with_params obj, render_ƒ, params
        return '' unless obj

        content = Element.render_obj( obj, render_ƒ, @engine )
        # content = Page.render_params( content, params ) if params
        content = @engine.running_app.obj.embedded_renderer.render content, params

        return content
      end

      # 
      # Render content with the given params.
      # Params might be nil, in which case the content
      # is returned with no changes.
      # 
      def self.render_params content, params
        return content unless params

        renderer = ERB.new( content )
        content = renderer.result_with_hash( params )

        return content
      end

    end
  end
end
