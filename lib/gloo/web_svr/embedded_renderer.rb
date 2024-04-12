# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# A helper class used to render parameters (ERB) in text.
# Also uses helper functions to render.
# 

module Gloo
  module WebSvr
    class EmbeddedRenderer
      
      HELPER = 'helper'.freeze

      attr_reader :engine, :log, :web_svr_obj


      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up the web server.
      #
      def initialize( engine, web_svr_obj )
        @engine = engine
        @log = @engine.log

        @web_svr_obj = web_svr_obj
      end


      # ---------------------------------------------------------------------
      #    Obj Helper Functions
      # ---------------------------------------------------------------------

      # 
      # Handle a missing method by looking for a helper function.
      # If there is one, then call it and return the result.
      # If not, log an error and return nil.
      # 
      def method_missing( method_name, *args )
        @log.debug "missing method '#{method_name}' with args #{args}"

        helper_pn = "#{HELPER}.#{method_name}"
        @log.debug "looking for function: #{helper_pn}"

        pn = Gloo::Core::Pn.new( @engine, helper_pn )
        obj = pn.resolve
        if obj
          @log.debug "found obj: #{obj.pn}"
          return obj.invoke args
        else
          @log.error "Function not found: #{helper_pn}"        
        end

        return nil
      end


      # ---------------------------------------------------------------------
      #    Renderer
      # ---------------------------------------------------------------------

      # 
      # Render content with the given params.
      # Params might be nil, in which case the content
      # is returned with no changes.
      # 
      def render content, params
        # If the params is nil, let's make it an empty hash.
        params = {} unless params

        # Get the binding context for this render.
        b = binding

        # Add the params to the binding context.
        params.each_pair do |key, value|
          b.local_variable_set key.to_sym, value
        end
      
        # Render in the current binding content.
        renderer = ERB.new( content )
        content = renderer.result( b )
      
        return content
      end

    end
    
  end
end
