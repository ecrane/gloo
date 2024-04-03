# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# A helper class for static assets.
# 

module Gloo
  module WebSvr
    class Asset
      
      ASSET_FOLDER = 'asset'.freeze

      CSS_TYPE = 'text/css'.freeze
      JS_TYPE = 'text/javascript'.freeze

      IMAGE_TYPE = 'image/'.freeze
      FAVICON_TYPE = 'image/x-icon'.freeze


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
      #    Asset Helpers
      # ---------------------------------------------------------------------

      # 
      # Find and return the page for the given route.
      # 
      def path_for_file file
        pn = file.value

        # Is the file's value a recognizable file?
        return pn if File.exist? pn

        # Look in the web server's asset folder.
        pn = File.join( @engine.settings.project_path, ASSET_FOLDER, pn )

        return pn
      end

      # 
      # Get the return type for the given file.
      # 
      def type_for_file file
        ext = File.extname( file ).downcase
        ext = ext[1..-1] if ext[0] == '.'
        
        if ext == 'css'
          return CSS_TYPE
        elsif ext == 'js'
          return JS_TYPE
        elsif ext == 'ico'
          return FAVICON_TYPE
        else
          return "#{IMAGE_TYPE}#{ext}"
        end
      end


      # ---------------------------------------------------------------------
      #    Render Asset
      # ---------------------------------------------------------------------

      # 
      # Helper to create a successful image response with the given data.
      # 
      def render_file( file )
        type = type_for_file file
        data = File.binread file 
        code = Gloo::WebSvr::ResponseCode::SUCCESS

        return Gloo::WebSvr::Response.new( @engine, code, type, data )
      end

    end
  end
end
