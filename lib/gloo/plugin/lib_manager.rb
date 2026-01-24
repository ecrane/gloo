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
      LIB_FILE = '_lib.rb'

      #
      # Set up the library manager.
      #
      def initialize( engine )
        @engine = engine
        @libraries = {}
        @engine.log.debug 'library manager intialized...'
      end

      # 
      # Get the loaded libraries.
      #
      def loaded_libraries
        return @libraries
      end

      # 
      # Get the start file for the library.
      # 
      def lib_start_file name
        root = @engine.settings.lib_path

        unless File.exist?( root )
          @engine.log.error "Library directory does not exist: #{root}"
          return nil
        end
        
        f = File.join( root, name, name + LIB_FILE )
        unless File.exist?( f )
          @engine.log.error "Library start file does not exist: #{f}"
          return nil
        end
        
        return f
      end

      # 
      # Load the library of the given name.
      # The name will correspond with the name of a directory
      # within the gloo libraries directory.
      #
      def load_lib( name )
        @engine.log.debug "Loading library: #{name}"
        fn = lib_start_file name

        unless fn
          @engine.log.error "Library start file not found for: #{name}"
          return
        end
        
        @libraries[name] = fn
        register_library name, fn
        @engine.log.debug "Library loaded: #{name}"
      end

      # 
      # Give the library a chance to register its verbs and objects.
      # 
      def register_library( name, full_path )
        require full_path

        class_name = name.capitalize + "Lib"
        @engine.log.debug "Looking for library to register: #{class_name}"
        begin
          plugin_class = Object.const_get( class_name )
          inst = plugin_class.new
          lib_cb = Callback.new( @engine )
          inst.register( lib_cb )
        rescue NameError
          @engine.log.error "Warning: Could not find class #{class_name} in file #{full_path}"
        end
      end

    end
  end
end
