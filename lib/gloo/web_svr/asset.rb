# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A helper class for static assets.
# 

module Gloo
  module WebSvr
    class Asset
      
      LIB_FOLDER = 'lib'.freeze
      ASSET_FOLDER = 'asset'.freeze
      IMAGE_FOLDER = 'image'.freeze
      STYLESHEET_FOLDER = 'stylesheet'.freeze
      JAVASCRIPT_FOLDER = 'javascript'.freeze

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
      #    lib asset Helpers
      # ---------------------------------------------------------------------

      # 
      # Get the asset folder in the User's lib.
      # Returns nil if it does not exist.
      #
      def lib_asset_folder
        dir = File.join( @engine.settings.user_root, LIB_FOLDER, ASSET_FOLDER )
        return dir if Dir.exist?( dir )

        return nil
      end

      # 
      # Get the stylesheets folder in the User's lib.
      # Returns nil if it does not exist.
      #
      def lib_stylesheet_folder
        dir = File.join( lib_asset_folder, STYLESHEET_FOLDER )
        return dir if Dir.exist?( dir )

        return nil
      end

      # 
      # Get the javascript folder in the User's lib.
      # Returns nil if it does not exist.
      #
      def lib_javascript_folder
        dir = File.join( lib_asset_folder, JAVASCRIPT_FOLDER )
        return dir if Dir.exist?( dir )

        return nil
      end

      # 
      # Get the images folder in the User's lib.
      # Returns nil if it does not exist.
      #
      def lib_image_folder
        dir = File.join( lib_asset_folder, IMAGE_FOLDER )
        return dir if Dir.exist?( dir )

        return nil
      end


      # ---------------------------------------------------------------------
      #    Asset Helpers
      # ---------------------------------------------------------------------

      # 
      # Get the asset folder in the project.
      #
      def asset_folder
        return File.join( @engine.settings.project_path, ASSET_FOLDER )
      end

      #
      # Get the images folder in the project.
      #
      def image_folder
        return File.join( asset_folder, IMAGE_FOLDER )
      end

      # 
      # Get the stylesheets folder in the project.
      #
      def stylesheet_folder
        return File.join( asset_folder, STYLESHEET_FOLDER )
      end

      # 
      # Get the stylesheets folder in the project.
      #
      def javascript_folder
        return File.join( asset_folder, JAVASCRIPT_FOLDER )
      end

      # 
      # Find and return the page for the given route.
      # 
      def path_for_file file
        pn = file.value

        # Is the file's value a recognizable file?
        return pn if File.exist? pn

        # Look in the web server's asset folder.
        pn = File.join( asset_folder, pn )

        # Try the lib assets if not found
        unless File.exist? pn
          lib = lib_asset_folder
          pn = File.join( lib, file.value ) if lib
        end

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

        return Gloo::WebSvr::Response.new( @engine, code, type, data, true )
      end

      #
      # Check if the given name is an asset.
      # 
      def is_asset? name
        return name == ASSET_FOLDER
      end


      # ---------------------------------------------------------------------
      #    Asset with Fingerprints
      # ---------------------------------------------------------------------

      # 
      # Register an asset with the web server.
      # Adds fingerprint to the file names for later access.
      # 
      # full_path is the FILE from which we build the SHA256 hash
      # pn is the path and name within the assets directory
      # name is the simple file name (icon.png)
      # 
      def register_asset name, pn, full_path
        asset_pn = "/asset/#{pn}"
        return AssetInfo.new( @engine, full_path, name, asset_pn ).register
      end

      # 
      # Get the published name for the given asset name.
      #
      def published_name asset_name
        return AssetInfo.find_published_name_for( asset_name )
      end


      # ---------------------------------------------------------------------
      #    Dynamic Add Assets
      # ---------------------------------------------------------------------

      # 
      # Add all asssets to the web server pages (routes).
      # 
      def add_asset_routes
        return unless File.exist? asset_folder

        @log.debug 'Adding asset routes to web server…'
        @factory = @engine.factory

        add_containers
        add_images
        add_stylesheets
        add_javascript
      end

      # 
      # Create the containers for the assets if they do not exist.
      #
      def add_containers
        pages = @web_svr_obj.pages_container

        @assets = pages.find_child( ASSET_FOLDER ) || 
          @factory.create_can( ASSET_FOLDER, pages )

        @images = @assets.find_child( IMAGE_FOLDER ) || 
          @factory.create_can( IMAGE_FOLDER, @assets )

        @stylesheets = @assets.find_child( STYLESHEET_FOLDER ) || 
          @factory.create_can( STYLESHEET_FOLDER, @assets )

        @javascript = @assets.find_child( JAVASCRIPT_FOLDER ) || 
          @factory.create_can( JAVASCRIPT_FOLDER, @assets )
      end

      # 
      # Traverse the given folder and add all files to the container.
      # This is a recursive method and look look for files in subfolders.
      # 
      def add_files_in_folder( folder, container, path )
        Dir.each_child( folder ) do |name|
          pn = File.join( path, name )
          full_path = File.join( folder, name )

          if File.directory? full_path
            child = container.find_child( name )
            child = @factory.create_can( name, container ) if child.nil?

            add_files_in_folder( full_path, child, pn )
          else
            info = register_asset( name, pn, full_path )
            add_file_obj( container, name, pn, info )
          end
        end
      end

      #
      # Add the images to the web server pages.
      #
      def add_images
        @log.debug 'Adding image asset routes to web server…'
        
        lib = lib_image_folder
        if lib
          add_files_in_folder( lib, @images, IMAGE_FOLDER )
        end

        return unless File.exist? image_folder

        # for each file in the images folder
        # create a file object and add it to the images container
        add_files_in_folder( image_folder, @images, IMAGE_FOLDER )
      end

      #
      # Add the stylesheets to the web server pages.
      #
      def add_stylesheets
        @log.debug 'Adding stylesheet asset routes to web server…'

        lib = lib_stylesheet_folder
        if lib
          add_files_in_folder( lib, @stylesheets, STYLESHEET_FOLDER )
        end

        return unless File.exist? stylesheet_folder

        # for each file in the stylesheets folder
        # create a file object and add it to the stylesheets container
        add_files_in_folder( stylesheet_folder, @stylesheets, STYLESHEET_FOLDER )

        # Dir.each_child( stylesheet_folder ) do |name|
        #   pn = File.join( STYLESHEET_FOLDER, name )
        #   add_file_obj( @stylesheets, name, pn )
        # end
      end

      #
      # Add the Javascript files to the web server pages.
      #
      def add_javascript
        @log.debug 'Adding javascript asset routes to web server…'

        lib = lib_javascript_folder
        if lib
          add_files_in_folder( lib, @javascript, JAVASCRIPT_FOLDER )
        end

        return unless File.exist? javascript_folder

        # for each file in the javascript folder
        # create a file object and add it to the javascript container
        add_files_in_folder( javascript_folder, @javascript, JAVASCRIPT_FOLDER )

        # Dir.each_child( javascript_folder ) do |name|
        #   pn = File.join( JAVASCRIPT_FOLDER, name )
        #   add_file_obj( @javascript, name, pn )
        # end
      end

      # 
      # Add a file object (page route) to the given container.
      # 
      def add_file_obj( can, name, pn, info )
        name = name.gsub( '.', '_' )
        @log.debug "Adding route for file: #{name}"

        # First make sure the child doesn't already exist.
        child = can.find_child( name )
        return if child

        @factory.create_file( name, pn, can )
        # @factory.create_file( info.published_name, pn, can )
      end


      # ---------------------------------------------------------------------
      #    List Asset Helpers
      # ---------------------------------------------------------------------

      # 
      # List all image assets.
      # This looks in the image container and lists the images found earlier.
      # A Debugging tool.
      # 
      def list_image_assets
        data = []
        @images.children.each do |o|
          data << [ o.name, o.pn, o.value ]
        end
        headers = [ "Name", "PN", "Value" ]

        puts Gloo::App::Platform::RETURN
        title = "Image Assets with Routes"
        @engine.platform.table.show headers, data, title
        puts Gloo::App::Platform::RETURN
      end

      # 
      # List all js assets.
      # This looks in the js container and lists the js files found earlier.
      # A Debugging tool.
      # 
      def list_js_assets
        data = []
        @javascript.children.each do |o|
          data << [ o.name, o.pn, o.value ]
        end
        headers = [ "Name", "PN", "Value" ]

        puts Gloo::App::Platform::RETURN
        title = "JavaScript Assets with Routes"
        @engine.platform.table.show headers, data, title
        puts Gloo::App::Platform::RETURN
      end

      # 
      # List all css assets.
      # This looks in the css container and lists the css files found earlier.
      # A Debugging tool.
      #
      def list_css_assets
        data = []
        @stylesheets.children.each do |o|
          data << [ o.name, o.pn, o.value ]
        end
        headers = [ "Name", "PN", "Value" ]

        puts Gloo::App::Platform::RETURN
        title = "Stylesheet Assets with Routes"
        @engine.platform.table.show headers, data, title        
        puts Gloo::App::Platform::RETURN
      end

    end
  end
end
