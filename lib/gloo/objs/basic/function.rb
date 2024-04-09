# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A Function that can be invoked inline in a script.
# It is also used as a helper for web pages.
#

module Gloo
  module Objs
    class Function < Gloo::Core::Obj

      KEYWORD = 'function'.freeze
      KEYWORD_SHORT = 'ƒ'.freeze

      # Events
      ON_INVOKE = 'on_invoke'.freeze

      # Parameters to the function invocation.
      PARAMS = 'params'.freeze

      # Return Value or container of objects
      RESULT = 'result'.freeze


      #
      # The name of the object type.
      #
      def self.typename
        return KEYWORD
      end

      #
      # The short name of the object type.
      #
      def self.short_typename
        return KEYWORD_SHORT
      end

      #
      # Set the value with any necessary type conversions.
      #
      def set_value( new_value )
        self.value = new_value.to_s
      end

      #
      # Set the value as an array.
      #
      def set_array_value( arr )
        self.value = arr
      end

      #
      # Does this object support multi-line values?
      # Initially only true for scripts.
      #
      def multiline_value?
        return false
      end

      # 
      # Get the result, the return value or container of objects.
      # 
      def result
        return_any = find_child RESULT

        # TODO: what does it look like to return objects?
        # if return_any is a container with children, return the container

        return return_any ? return_any.value : nil
      end


      # ---------------------------------------------------------------------
      #    Children
      # ---------------------------------------------------------------------

      #
      # Does this object have children to add when an object
      # is created in interactive mode?
      # This does not apply during obj load, etc.
      #
      def add_children_on_create?
        return true
      end

      #
      # Add children to this object.
      # This is used by containers to add children needed
      # for default configurations.
      #
      def add_default_children
        fac = @engine.factory

        fac.create_can PARAMS, self
        fac.create_script ON_INVOKE, '', self
        fac.create_untyped RESULT, '', self
      end


      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      #
      # Get a list of message names that this object receives.
      #
      def self.messages
        return super + [ 'invoke' ]
      end

      #
      # Send the object the invoke message.
      # Invoke the functdion and return the result.
      #
      def msg_invoke
        return invoke
      end


      # ---------------------------------------------------------------------
      #    Events
      # ---------------------------------------------------------------------

      #
      # Run the on invoke script if there is one.
      #
      def run_on_invoke
        o = find_child ON_INVOKE
        return unless o

        Gloo::Exec::Dispatch.message( @engine, 'run', o )
      end


      # ---------------------------------------------------------------------
      #    Messages
      # ---------------------------------------------------------------------

      # 
      # Invoke the function, run the script and return the result.
      # 
      def invoke
        @engine.log.debug "Invoking function: #{name}"

        # TODO: Populate the parameters
        # How do they get set?

        run_on_invoke

        return_value = result
        @engine.heap.it.set_to return_value
        
        return return_value
      end

    end
  end
end
