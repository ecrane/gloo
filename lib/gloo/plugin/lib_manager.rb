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

      PINNED_ERR = "Could not unload library '%s': gloo loaded it itself, so it stays loaded.".freeze
      IN_USE_ERR = "Could not unload library '%s': objects of its types are on the heap (%s).".freeze

      #
      # Set up the library manager.
      #
      def initialize( engine )
        @engine = engine
        @libraries = {}
        # What each library registered (its Callback), for unloading.
        @registrations = {}
        # Libraries gloo loaded itself; unloading them is an error.
        @pinned = []
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
      # A pinned library is one gloo loads itself (gloo-test, in test
      # mode): it can't be unloaded, and survives a session reset.
      #
      def load_lib( name, pinned: false )
        @pinned << name if pinned && !@pinned.include?( name )

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
          @registrations[ name ] = lib_cb
          inst.register( lib_cb )
        rescue NameError
          @engine.err "Could not find class '#{class_name}' in library '#{name}'."
        end
      end


      #
      # Is the library one gloo loaded itself (see load_lib)?
      #
      def pinned?( name )
        return @pinned.include?( name )
      end

      #
      # Unload the library of the given name: take its verbs and object
      # types out of the dictionary, and forget it's loaded. The Ruby
      # code stays loaded (it can't be un-required), so load_lib
      # registers it again. Not done, and an error, for a pinned
      # library or while objects of its types are on the heap.
      # Unloading a library that isn't loaded does nothing.
      # Returns false if it couldn't be unloaded, true otherwise.
      #
      def unload_lib( name )
        unless @libraries.key?( name )
          @engine.log.info "Library #{name} isn't loaded."
          return true
        end

        if pinned?( name )
          @engine.err format( PINNED_ERR, name )
          return false
        end

        cb = @registrations[ name ]
        in_use = cb ? cb.objects_in_use : []
        unless in_use.empty?
          @engine.err format( IN_USE_ERR, name, in_use.map( &:pn ).join( ', ' ) )
          return false
        end

        cb&.unregister
        @registrations.delete( name )
        @libraries.delete( name )
        @engine.log.debug "Core library unloaded: #{name}"
        return true
      end


      #
      # Unload every library except the pinned ones (see load_lib), as
      # for a session reset. Called with the heap already emptied, so no
      # object of a library's types can stop it.
      #
      def unload_unpinned
        ( @libraries.keys - @pinned ).each { |name| unload_lib( name ) }
      end

    end
  end
end
