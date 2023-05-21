# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An object factory.
#

module GlooLang
  module Core
    class Factory < Baseo

      # ---------------------------------------------------------------------
      #    Initializer
      # ---------------------------------------------------------------------

      #
      # Set up the object factory.
      #
      def initialize( engine )
        @engine = engine
        @engine.log.debug 'object factory intialized...'
      end

      # ---------------------------------------------------------------------
      #    Factory Helpers
      # ---------------------------------------------------------------------

      #
      # Helper shortcut to create an alias child object.
      #
      def create_alias( name, value, parent )
        params = { :name => name,
                   :type => 'alias',
                   :value => value,
                   :parent => parent }
        create params
      end

      #
      # Helper shortcut to create a string child object.
      #
      def create_untyped( name, value, parent )
        params = { :name => name,
                   :type => 'untyped',
                   :value => value,
                   :parent => parent }
        create params
      end

      #
      # Helper shortcut to create a string child object.
      #
      def create_string( name, value, parent )
        params = { :name => name,
                   :type => 'string',
                   :value => value,
                   :parent => parent }
        create params
      end

      #
      # Helper shortcut to create a text child object.
      #
      def create_text( name, value, parent )
        params = { :name => name,
                   :type => 'text',
                   :value => value,
                   :parent => parent }
        create params
      end

      #
      # Helper shortcut to create an integer child object.
      #
      def create_int( name, value, parent )
        params = { :name => name,
                   :type => 'integer',
                   :value => value,
                   :parent => parent }
        create params
      end

      #
      # Helper shortcut to create a boolean child object.
      #
      def create_bool( name, value, parent )
        params = { :name => name,
                   :type => 'boolean',
                   :value => value,
                   :parent => parent }
        create params
      end

      #
      # Helper shortcut to create a container child object.
      #
      def create_can( name, parent )
        params = { :name => name,
                   :type => 'container',
                   :value => nil,
                   :parent => parent }
        create params
      end

      #
      # Helper shortcut to create a script child object.
      #
      def create_script( name, value, parent )
        params = { :name => name,
                   :type => 'script',
                   :value => value,
                   :parent => parent }
        create params
      end

      #
      # Helper shortcut to create a file child object.
      #
      def create_file( name, value, parent )
        params = { :name => name,
                   :type => 'file',
                   :value => value,
                   :parent => parent }
        create params
      end

      # ---------------------------------------------------------------------
      #    Object Factory
      # ---------------------------------------------------------------------

      # Create object with given name, type and value.
      # One of either name or type is required.
      # All values are optional when considered on their own.
      # Parameter hash keys:
      #  :name - the name of the object
      #  :type - the name of the type
      #  :value - the initial object value
      #  :parent - the parent object
      #  :squash_duplicates - if the object exists, use it rather
      #                       than creating a new one?  Default = true
      def create( params )
        objtype = find_type params[ :type ]
        return nil unless objtype

        pn = GlooLang::Core::Pn.new( @engine, params[ :name ] )
        parent = params[ :parent ]
        if parent.nil?
          parent = pn.get_parent
          obj_name = pn.name
        else
          obj_name = params[ :name ]
        end

        if pn.exists? && params[ :squash_duplicates ]
          @engine.log.debug "Updating existing object: #{obj_name}"
          return self.update_existing pn, params[ :value ]
        end

        @engine.log.debug "Creating new object: #{obj_name}"
        return create_new obj_name, params[ :value ], objtype, parent
      end

      #
      # Create a new object.
      #
      def create_new( name, value, type, parent )
        unless parent
          @engine.log.error "Could not create object.  Bad path: #{name}"
          return nil
        end

        o = type.new( @engine )
        o.name = name
        o.set_value value
        parent.add_child( o )
        return o
      end

      #
      # Find and Update an existing object.
      #
      def update_existing( pn, value )
        o = pn.resolve
        o.set_value value
        return o
      end

      #
      # Find the object type by name.
      # Return nil if the object type cannot be found or
      # cannot be created.
      #
      def find_type( type_name )
        type_name = 'untyped' if type_name.nil? || type_name.strip.empty?
        t = @engine.dictionary.find_obj( type_name )

        if t.nil?
          @engine.log.warn "Could not find type, '#{type_name}'"
          return nil
        end

        unless t.can_create?
          @engine.log.error "'#{type_name}' cannot be created."
          return nil
        end

        return t
      end

    end
  end
end
