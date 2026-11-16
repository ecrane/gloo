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

      IN_USE_ERR = "Could not unload extension '%s': objects of its types are on the heap (%s).".freeze

      #
      # Set up the extension manager.
      #
      def initialize( engine )
        @engine = engine
        @extensions = {}
        # What each extension registered (its Callback), for unloading.
        @registrations = {}
        @engine.log.debug 'extension manager initialized...'
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
          @engine.err Gloo::Core::NotFound.folder( root )
          return nil
        end
        
        f = File.join( root, name, name + EXT_FILE )
        unless File.exist?( f )
          @engine.err Gloo::Core::NotFound.file( f )
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
        if @extensions.key?( name )
          @engine.log.info "Extension #{name} is already loaded."
          return
        end
        
        @engine.log.debug "Loading extension: #{name}"
        fn = ext_start_file name

        # ext_start_file has already reported what's missing.
        return unless fn
        
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
          @registrations[ name ] = ext_cb
          inst.register( ext_cb )
        rescue NameError
          @engine.err "Could not find class '#{class_name}' in extension file '#{full_path}'."
        end
      end


      #
      # Unload the extension of the given name: take its verbs and
      # object types out of the dictionary, and forget it's loaded. The
      # Ruby code stays loaded, so load_ext registers it again. Not
      # done, and an error, while objects of its types are on the heap.
      # Unloading an extension that isn't loaded does nothing.
      # Returns false if it couldn't be unloaded, true otherwise.
      #
      def unload_ext( name )
        unless @extensions.key?( name )
          @engine.log.info "Extension #{name} isn't loaded."
          return true
        end

        cb = @registrations[ name ]
        in_use = cb ? cb.objects_in_use : []
        unless in_use.empty?
          @engine.err format( IN_USE_ERR, name, in_use.map( &:pn ).join( ', ' ) )
          return false
        end

        cb&.unregister
        @registrations.delete( name )
        @extensions.delete( name )
        @engine.log.debug "Extension unloaded: #{name}"
        return true
      end


      #
      # Unload every extension, as for a session reset. Called with the
      # heap already emptied, so no object of an extension's types can
      # stop it.
      #
      def unload_all
        @extensions.keys.each { |name| unload_ext( name ) }
      end

    end
  end
end
