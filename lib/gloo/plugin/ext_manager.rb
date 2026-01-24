# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2026 Eric Crane.  All rights reserved.
#
# The Extension Manager.
# Load extensions as needed and register their verbs and objects.
#

module Gloo
  module Plugin
    class ExtManager

      # Constants for extension management
      EXT_FILE = '_ext.rb'

      #
      # Set up the extension manager.
      #
      def initialize( engine )
        @engine = engine
        @extensions = {}
        @engine.log.debug 'extension manager intialized...'
      end

      # 
      # Get the loaded extensions.
      #
      def loaded_extensions
        return @extensions
      end

      # 
      # Get the start file for the extension.
      # 
      def ext_start_file name
        root = @engine.settings.ext_path

        unless File.exist?( root )
          @engine.log.error "Extension directory does not exist: #{root}"
          return nil
        end
        
        f = File.join( root, name, name + EXT_FILE )
        unless File.exist?( f )
          @engine.log.error "Extension start file does not exist: #{f}"
          return nil
        end
        
        return f
      end

      # 
      # Load the extension of the given name.
      # The name will correspond with the name of a directory
      # within the gloo extensions directory.
      #
      def load_ext( name )
        @engine.log.debug "Loading extension: #{name}"
        fn = ext_start_file name

        unless fn
          @engine.log.error "Extension start file not found for: #{name}"
          return
        end
        
        @extensions[name] = fn
        register_extension name, fn
        @engine.log.debug "Extension loaded: #{name}"
      end

      # 
      # Give the extension a chance to register its verbs and objects.
      # 
      def register_extension( name, full_path )
        require full_path

        class_name = name.capitalize + "Ext"
        @engine.log.debug "Looking for extension to register: #{class_name}"
        begin
          plugin_class = Object.const_get( class_name )
          inst = plugin_class.new
          ext_cb = Callback.new( @engine )
          inst.register( ext_cb )
        rescue NameError
          @engine.log.error "Warning: Could not find class #{class_name} in file #{full_path}"
        end
      end

    end
  end
end
