# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# The Library Manager.
# Load libraries as needed and register their verbs and objects.
#

module Gloo
  module Plugin
    class LibManager

      # Constants for library management
      GEM_PREFIX = 'gloo-'
      INIT_CLASS_SUFFIX = 'Init'

      #
      # Set up the library manager.
      #
      def initialize( engine )
        @engine = engine
        @libraries = {}
        @engine.log.debug 'library manager initialized...'
      end

      # 
      # Get the loaded libraries.
      #
      def loaded_libraries
        return @libraries
      end

      # 
      # Get the start file for the gem core library.
      # 
      def core_lib_name name
        return GEM_PREFIX + name
      end

      # 
      # Get the library initialization class name.
      # 
      def init_class_name name
        return name.camelize + INIT_CLASS_SUFFIX
      end

      # 
      # Load the library of the given name.
      # The name will correspond with the name of a directory
      # within the gloo libraries directory.
      #
      def load_lib( name )
        # Check to see if the library is already loaded.
        if @libraries.key?( name )
          @engine.log.info "Library #{name} is already loaded."
          return
        end

        @engine.log.debug "Loading core library: #{name}"
        gem_name = core_lib_name name
        
        @libraries[name] = gem_name
        register_library name, gem_name
        @engine.log.debug "Core library loaded: #{name}"
      end

      # 
      # Require a gem by name, installing it if it's not available.
      #
      def require_gem gem_name
        @engine.log.debug "Going to require gem: #{gem_name}"
        begin
          gem gem_name
        rescue Gem::LoadError
          @engine.log.info "Gem not found, attempting to install: #{gem_name}"
          system("gem install #{gem_name}")
          Gem.clear_paths
          gem gem_name
        end

        require gem_name
      end

      # 
      # Give the library a chance to register its verbs and objects.
      # 
      def register_library( name, gem_name )
        require_gem gem_name

        class_name = init_class_name name
        @engine.log.debug "Looking for library entry point class to register: #{class_name}"
        begin
          plugin_class = Object.const_get( class_name )
          inst = plugin_class.new
          lib_cb = Callback.new( @engine )
          inst.register( lib_cb )
        rescue NameError => ex
          @engine.log.error "Warning: Could not find class #{class_name}", ex
        end
      end

    end
  end
end
