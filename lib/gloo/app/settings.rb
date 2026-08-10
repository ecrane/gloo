# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Application and user settings.
#

require 'yaml'

module Gloo
  module App
    class Settings

      DEFAULT_THEME = 'dark'.freeze
      THEMES = %w[dark light].freeze

      attr_reader :user_root, :log_path,
        :config_path, :project_path, :ext_path,
        :start_with, :list_indent, :list_levels, :tmp_path,
        :debug_path, :debug, :theme

      #
      # Load setting from the yml file.
      # The mode parameter is used to determine if we are running in TEST.
      #
      def initialize( engine, root=nil )
        @engine = engine
        # @mode = mode
        init_root( root )

        init_path_settings
        init_user_settings
      end

      #
      # Show the current application settings.
      # Can be seen in app with 'help settings'
      #
      def show
        theme = @engine.theme
        puts theme.heading( "\n Application Settings:" )
        puts theme.accent( '   Startup with:  ' ) + theme.emphasis( @start_with.to_s )
        puts theme.accent( '   Indent in Listing:  ' ) + theme.emphasis( @list_indent.to_s )
        puts theme.accent( '   List Levels:  ' ) + theme.emphasis( @list_levels.to_s )
        puts theme.accent( '   Debug?  ' ) + theme.emphasis( @debug.to_s )
        puts theme.accent( '   Theme:  ' ) + theme.emphasis( @theme )
        puts theme.accent( '   Screen Lines:  ' ) + theme.emphasis( Gloo::App::Settings.lines( @engine ).to_s )
        puts theme.accent( '   Page Size:  ' ) + theme.emphasis( Gloo::App::Settings.page_size( @engine ).to_s )
        self.show_paths
      end

      #
      # Show path settings
      #
      def show_paths
        theme = @engine.theme
        puts theme.heading( "\n Application Paths:" )
        puts theme.accent( '   User Root Path is here:  ' ) + theme.emphasis( @user_root )
        puts theme.accent( '   Projects Path:  ' ) + theme.emphasis( @project_path )
        puts theme.accent( '   Extensions Path:  ' ) + theme.emphasis( @ext_path )
        puts theme.accent( '   Tmp Path:  ' ) + theme.emphasis( @tmp_path )
        puts theme.accent( '   Debug Path:  ' ) + theme.emphasis( @debug_path )
        puts "\n"
      end

      #
      # Get the number of vertical lines on screen.
      #
      def self.lines engine
        engine.platform.lines
      end

      #
      # Get the number of horizontal columns on screen.
      #
      def self.cols engine
        engine.platform.cols
      end

      #
      # Get the default page size.
      # This is the number of lines of text we can show.
      #
      def self.page_size engine
        Settings.lines( engine ) - 3
      end

      #
      # How many lines should we use for a preview?
      #
      def self.preview_lines
        return 7
      end

      # ---------------------------------------------------------------------
      #    Functions
      # ---------------------------------------------------------------------

      # 
      # Running in app mode, so overriding the root project path.
      # 
      def override_project_path path
        @engine.log.debug "Root project path is #{path}"

        @project_path = path
      end

      # ---------------------------------------------------------------------
      #    Private
      # ---------------------------------------------------------------------

      private

      #
      # Initialize gloo's root path.
      #
      def init_root root
        if root
          @user_root = root
        else
          @user_root = File.join( Dir.home, 'gloo' )
        end
      end

      #
      # Get the app's required directories.
      #
      def init_path_settings
        Dir.mkdir( @user_root ) unless File.exist?( @user_root )

        @log_path = File.join( @user_root, 'logs' )
        Dir.mkdir( @log_path ) unless File.exist?( @log_path )

        @config_path = File.join( @user_root, 'config' )
        Dir.mkdir( @config_path ) unless File.exist?( @config_path )

        @ext_path = File.join( @user_root, 'extensions' )
        Dir.mkdir( @ext_path ) unless File.exist?( @ext_path )

        @tmp_path = File.join( @user_root, 'tmp' )
        Dir.mkdir( @tmp_path ) unless File.exist?( @tmp_path )

        @debug_path = File.join( @user_root, 'debug' )
        Dir.mkdir( @debug_path ) unless File.exist?( @debug_path )
      end

      #
      # Initialize the user settings for the currently
      # running environment.
      #
      def init_user_settings
        settings = get_settings

        @project_path = settings[ 'gloo' ][ 'project_path' ]
        if @project_path.blank?
          @project_path = File.join( @user_root, 'projects' )
        end

        @start_with = settings[ 'gloo' ][ 'start_with' ]
        @list_indent = settings[ 'gloo' ][ 'list_indent' ]
        @list_levels = settings[ 'gloo' ][ 'list_levels' ]

        @debug = settings[ 'gloo' ][ 'debug' ]

        @theme = settings[ 'gloo' ][ 'theme' ]&.strip&.downcase
        @theme = DEFAULT_THEME unless THEMES.include?( @theme )
      end

      #
      # Get the app's required directories.
      #
      def get_settings
        f = File.join( @config_path, 'gloo.yml' )
        create_settings( f ) unless File.exist?( f )
        return YAML.load_file f
      end

      #
      # Create settings file.
      #
      def create_settings( file )
        IO.write( file, get_default_settings )
      end

      #
      # Get the value for default settings.
      #
      def get_default_settings
        projects = File.join( @user_root, 'projects' )
        str = <<~TEXT
          gloo:
            project_path: #{projects}
            start_with:
            list_indent: 2
            list_levels: 3
            debug: false
            theme: #{DEFAULT_THEME}
        TEXT
        return str
      end

    end
  end
end
