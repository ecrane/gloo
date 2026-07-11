# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# The Event Manager.
# Run scripts in response to pre-defined events.
#

module Gloo
  module Core
    class EventManager

      #
      # Set up the event manager.
      #
      def initialize( engine )
        @engine = engine
        @engine.log.debug 'event manager intialized...'
      end

      #
      # Run on_load scripts in the recently loaded object
      # If no obj is given the script will be run in root.
      #
      def on_load( obj = nil, in_heap = false )
        return unless obj || in_heap

        @engine.log.debug 'on_load event'
        arr = Gloo::Core::ObjFinder.by_name( @engine, 'on_load', obj )
        arr.each { |o| Gloo::Exec::Dispatch.message( @engine, 'run', o ) }
      end

      #
      # Run on_unload scripts in the object that will be unloaded.
      #
      def on_unload( obj )
        return unless obj

        @engine.log.debug 'on_unload event'
        arr = Gloo::Core::ObjFinder.by_name( @engine, 'on_unload', obj )
        arr.each { |o| Gloo::Exec::Dispatch.message( @engine, 'run', o ) }
      end

      #
      # Run on_reload scripts in the object that will be reloaded.
      #
      def on_reload( obj )
        return unless obj

        @engine.log.debug 'on_reload event'
        arr = Gloo::Core::ObjFinder.by_name( @engine, 'on_reload', obj )
        arr.each { |o| Gloo::Exec::Dispatch.message( @engine, 'run', o ) }
      end

      #
      # Run on_save scripts in the object that is being saved.
      #
      def on_save( obj )
        return unless obj

        @engine.log.debug 'on_save event'
        arr = Gloo::Core::ObjFinder.by_name( @engine, 'on_save', obj )
        arr.each { |o| Gloo::Exec::Dispatch.message( @engine, 'run', o ) }
      end

      #
      # Run on_quit scripts in any open objets.
      # If no obj is given the script will be run in root.
      #
      def on_quit
        @engine.log.debug 'on_quit event'
        arr = Gloo::Core::ObjFinder.by_name( @engine, 'on_quit' )
        arr.each { |o| Gloo::Exec::Dispatch.message( @engine, 'run', o ) }
      end

      # 
      # Run the on_error scripts in any open objects.
      # For each on_error script found, look for the error_data container
      # and set the error message and backtrace.
      # 
      def on_error msg, backtrace
        @engine.log.debug 'on_error event'
        arr = Gloo::Core::ObjFinder.by_name( @engine, 'on_error' )
        arr.each do |o|
          data = o.parent.find_child 'error_data'
          if data
            data.find_child( 'message' ).set_value msg
            data.find_child( 'backtrace' ).set_value backtrace
          end

          Gloo::Exec::Dispatch.message( @engine, 'run', o )
        end
      end

      #
      # Run the on_exception scripts in any open objects.
      # For each on_exception script found, look for the exception_data
      # container and set the exception message and backtrace.
      #
      def on_exception msg, backtrace
        @engine.log.debug 'on_exception event'
        arr = Gloo::Core::ObjFinder.by_name( @engine, 'on_exception' )
        arr.each do |o|
          data = o.parent.find_child 'exception_data'
          if data
            data.find_child( 'message' ).set_value msg
            data.find_child( 'backtrace' ).set_value backtrace
          end

          Gloo::Exec::Dispatch.message( @engine, 'run', o )
        end
      end

    end
  end
end
