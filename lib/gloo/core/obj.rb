# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# An data/value object.
# Derives from the Baseo object.  Is not a verb.
#

module Gloo
  module Core
    class Obj < Baseo

      attr_accessor :value
      attr_reader :children, :parent

      #
      # Set up the object.
      #
      def initialize
        @value = ''
        @children = []
        @parent = nil
      end

      #
      # Register object types when they are loaded.
      #
      def self.inherited( subclass )
        Dictionary.instance.register_obj( subclass )
      end

      #
      # The name of the object type.
      #
      def self.typename
        raise 'this method should be overriden'
      end

      #
      # The object type, suitable for display.
      #
      def type_display
        return self.class.typename
      end

      #
      # Set the parent for the object.
      #
      def set_parent( obj )
        @parent = obj
      end

      #
      # Is this the root object?
      #
      def root?
        return false if @parent
        return false unless name.downcase == 'root'

        return true
      end

      # Can this object be created?
      # This is true by default and only false for some special cases
      # such as the System object.
      def self.can_create?
        true
      end

      #
      # Get the path and name to this object.
      #
      def pn
        str = self.name
        p = self.parent
        while p && !p.root?
          str = "#{p.name}.#{str}"
          p = p.parent
        end
        return str
      end

      #
      # Generic function to get display value.
      # Can be used for debugging, etc.
      #
      def display_value
        return self.pn
      end

      # ---------------------------------------------------------------------
      #    Value
      # ---------------------------------------------------------------------

      #
      # Set the value with any necessary type conversions.
      #
      def set_value( new_value )
        self.value = new_value
      end

      #
      # Get the value for display purposes.
      #
      def value_display
        return self.value.to_s
      end

      #
      # Does this object support multi-line values?
      # Initially only true for scripts.
      #
      def multiline_value?
        return false
      end

      #
      # Is the value a String?
      #
      def value_string?
        return self.value.is_a? String
      end

      #
      # Is the value an Array?
      #
      def value_is_array?
        return self.value.is_a? Array
      end

      #
      # Is the value a blank string?
      #
      def value_is_blank?
        return true if value.nil?

        return self.value.to_s.strip.empty?
      end

      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      #
      # Find a child of the given name.
      # If found, return it.  If not found create it.
      #
      def find_add_child( name, type )
        child = self.find_child( name )
        return child if child

        params = { :name => name,
                   :type => type,
                   :value => nil,
                   :parent => self }
        return $engine.factory.create params
      end

      #
      # Add a child object to the container.
      #
      def add_child( obj )
        @children << obj
        obj.set_parent self
      end

      #
      # Get the number of children.
      #
      def child_count
        return @children.count
      end

      #
      # Does this object contain an object with the given name?
      #
      def contains_child?( name )
        @children.each do |o|
          return true if name.downcase == o.name.downcase
        end
        return false
      end

      #
      # Find a child object with the given name.
      #
      def find_child( name )
        if name.end_with?( Gloo::Objs::Alias::ALIAS_REFERENCE )
          name = name[ 0..-2 ]
        end

        @children.each do |o|
          return o if name.downcase == o.name.downcase
        end

        if self.type_display == Gloo::Objs::Alias.typename
          ln = Gloo::Core::Pn.new( self.value )
          redirect = ln.resolve
          return redirect.find_child( name )
        end
        return nil
      end

      #
      # Delete all children from the container.
      #
      def delete_children
        @children.reverse.each do |o|
          self.remove_child o
        end
      end

      #
      # Remove the object from the children collection.
      #
      def remove_child( obj )
        @children.delete obj
      end

      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      def add_children_on_create?
        return false
      end

      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      def add_default_children
        # Override this.
      end

      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return %w[unload]
      end

      #
      # Can this object receive a message?
      #
      def can_receive_message?( msg )
        msgs = self.class.messages
        return msgs.include?( msg.strip.downcase )
      end

      #
      # Sent this object the given message.
      #
      def send_message( msg, params = nil )
        @params = params
        return self.dispatch msg if self.can_receive_message? msg

        $log.error "Object #{self.name} cannot receive message #{msg}"
        return false
      end

      #
      # Dispatch the message to the object.
      #
      def dispatch( msg )
        o = "msg_#{msg}"
        if self.respond_to? o
          self.public_send( o )
          return true
        else
          $log.error "Message #{msg} not implemented"
          return false
        end
      end

      #
      # Send the object the unload message.
      #
      def msg_unload
        if self.root?
          $log.error 'Cannot unload the root object.'
          return
        end

        $engine.event_manager.on_unload self
        $engine.heap.unload self
      end

      # ---------------------------------------------------------------------
      #    Help
      # ---------------------------------------------------------------------

      #
      # Get help for this object.
      #
      def self.help
        return 'No help found.'
      end

    end
  end
end
