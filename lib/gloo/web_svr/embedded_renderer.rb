# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# A helper class used to render parameters (ERB) in text.
# Also uses helper functions to render.
# 

module Gloo
  module WebSvr
    class EmbeddedRenderer
      
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

      def method_missing( method_name, *args )
        puts "1 missing #{method_name} with args #{args}"
        return "Hello World"
      end
      
      def hello1
        return "Hello World"
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
