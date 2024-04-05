# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# A helper class for static assets.
# 

module Gloo
  module WebSvr
    class Asset
      
      ASSETS_FOLDER = 'assets'.freeze
      IMAGES_FOLDER = 'images'.freeze
      STYLESHEETS_FOLDER = 'stylesheets'.freeze

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
      # Get the asset folder in the project.
      #
      def assets_folder
        return File.join( @engine.settings.project_path, ASSETS_FOLDER )
      end

      #
      # Get the images folder in the project.
      #
      def images_folder
        return File.join( assets_folder, IMAGES_FOLDER )
      end

      # 
      # Get the stylesheets folder in the project.
      #
      def stylesheets_folder
        return File.join( assets_folder, STYLESHEETS_FOLDER )
      end

      # 
      # Find and return the page for the given route.
      # 
      def path_for_file file
        pn = file.value

        # Is the file's value a recognizable file?
        return pn if File.exist? pn

        # Look in the web server's asset folder.
        pn = File.join( assets_folder, pn )

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


      # ---------------------------------------------------------------------
      #    Dynamic Add Assets
      # ---------------------------------------------------------------------

      # 
      # Add all asssets to the web server pages (routes).
      # 
      def add_asset_routes
        return unless File.exist? assets_folder

        @log.debug 'Adding asset routes to web server…'
        @factory = @engine.factory

        add_containers
        add_images
        add_stylesheets
      end

      # 
      # Create the containers for the assets if they do not exist.
      #
      def add_containers
        pages = @web_svr_obj.pages_container

        @assets = pages.find_child( ASSETS_FOLDER ) || 
          @factory.create_can( ASSETS_FOLDER, pages )

        @images = @assets.find_child( IMAGES_FOLDER ) || 
          @factory.create_can( IMAGES_FOLDER, @assets )

        @stylesheets = @assets.find_child( STYLESHEETS_FOLDER ) || 
          @factory.create_can( STYLESHEETS_FOLDER, @assets )
      end

      #
      # Add the images to the web server pages.
      #
      def add_images
        @log.debug 'Adding image asset routes to web server…'
        
        return unless File.exist? images_folder

        # for each file in the images folder
        # create a file object and add it to the images container
        Dir.each_child( images_folder ) do |name|
          pn = File.join( IMAGES_FOLDER, name )
          add_file_obj( @images, name, pn )
        end
      end

      #
      # Add the stylesheets to the web server pages.
      #
      def add_stylesheets
        @log.debug 'Adding stylesheet asset routes to web server…'

        return unless File.exist? stylesheets_folder

        # for each file in the stylesheets folder
        # create a file object and add it to the stylesheets container
        Dir.each_child( stylesheets_folder ) do |name|
          pn = File.join( STYLESHEETS_FOLDER, name )
          add_file_obj( @stylesheets, name, pn )
        end
      end

      # 
      # Add a file object (page route) to the given container.
      # 
      def add_file_obj( can, name, pn )
        name = name.gsub( '.', '_' )
        @log.debug "Adding route for file: #{name}"

        # First make sure the child doesn't already exist.
        child = can.find_child( name )
        return if child

        @factory.create_file( name, pn, can )
      end

    end
  end
end
