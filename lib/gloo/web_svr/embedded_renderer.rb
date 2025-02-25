# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A helper class used to render parameters (ERB) in text.
# Also uses helper functions to render.
# 

module Gloo
  module WebSvr
    class EmbeddedRenderer
      
      HELPER = 'helper'.freeze

      attr_reader :engine, :log, :web_svr_obj


      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine, web_svr_obj )
        @engine = engine
        @log = @engine.log

        @web_svr_obj = web_svr_obj
      end


      # ---------------------------------------------------------------------
      #    Tag Helpers
      # ---------------------------------------------------------------------

      # 
      # Render a favicon tag.
      # By default the name is 'favicon.ico' and does not need to be provided
      # if that is the correct file name.
      # 
      def favicon_tag( name = 'favicon.ico' )
        icon_path = "/#{Asset::ASSET_FOLDER}/#{Asset::IMAGE_FOLDER}/#{name}"
        published_name = @engine.running_app.obj.asset.published_name( icon_path )
        return "<link rel='shortcut icon' type='image/x-icon' href='#{published_name}' />"
      end

      # 
      # Render a Apple Touch Icon tag.
      # By default the name is 'apple-touch-icon.png' and does not need to be provided
      # if that is the correct file name.
      # 
      def apple_touch_icon_tag( name = 'apple-touch-icon.png', type = 'image/png' )
        icon_path = "/#{Asset::ASSET_FOLDER}/#{Asset::IMAGE_FOLDER}/#{name}"
        published_name = @engine.running_app.obj.asset.published_name( icon_path )
        return "<link rel='apple-touch-icon' type='#{type}' href='#{published_name}' />"
      end

      # 
      # Render an image tag for the given image name.
      # Include optional proterties as part of the tag.
      #
      def image_tag( img_name, properties = '' )
        image_path = "/#{Asset::ASSET_FOLDER}/#{Asset::IMAGE_FOLDER}/#{img_name}"
        published_name = @engine.running_app.obj.asset.published_name( image_path )
        return "<image src='#{published_name}' #{properties} />"
      end

      # 
      # Render a script tag for the given script name.
      #
      def js_tag( name )
        js_path = "/#{Asset::ASSET_FOLDER}/#{Asset::JAVASCRIPT_FOLDER}/#{name}"
        published_name = @engine.running_app.obj.asset.published_name( js_path )
        return "<script src='#{published_name}'></script>"
      end

      #
      # Render a stylesheet tag for the given stylesheet name.
      #
      def css_tag( name )
        css_path = "/#{Asset::ASSET_FOLDER}/#{Asset::STYLESHEET_FOLDER}/#{name}"
        published_name = @engine.running_app.obj.asset.published_name( css_path )
        return "<link rel='stylesheet' media='all' href='#{published_name}' />"
      end

      # 
      # Embed a hidden field with the autenticity token.
      # 
      def autenticity_token_tag
        session_id = @engine.running_app.obj&.session&.get_session_id
        return Gloo::Objs::CsrfToken.get_csrf_token_hidden_field( session_id )
      end


      # ---------------------------------------------------------------------
      #    Obj Helper Functions
      # ---------------------------------------------------------------------

      # 
      # Handle a missing method by looking for a helper function.
      # If there is one, then call it and return the result.
      # If not, log an error and return nil.
      # 
      def method_missing( method_name, *args )
        @log.debug "missing method '#{method_name}' with args #{args}"

        helper_pn = "#{HELPER}.#{method_name}"
        @log.debug "looking for function: #{helper_pn}"

        pn = Gloo::Core::Pn.new( @engine, helper_pn )
        obj = pn.resolve
        if obj
          @log.debug "found obj: #{obj.pn}"
          return obj.invoke args
        else
          @log.error "Function not found: #{helper_pn}"        
        end

        return nil
      end


      # ---------------------------------------------------------------------
      #    Renderer
      # ---------------------------------------------------------------------

      # 
      # Render content with the given params.
      # Params might be nil, in which case the content
      # is returned with no changes.
      # 
      def render content, params
        # If the params is nil, let's make it an empty hash.
        params = {} unless params

        # Get the binding context for this render.
        b = binding

        # Add the params to the binding context.
        params.each_pair do |key, value|
          b.local_variable_set key.to_sym, value
        end
      
        # Render in the current binding content.
        renderer = ERB.new( content )
        content = renderer.result( b )
      
        return content
      end

    end
    
  end
end
