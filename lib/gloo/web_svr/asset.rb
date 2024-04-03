# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# A helper class for static assets.
# 

module Gloo
  module WebSvr
    class Asset
      
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
      #    Asset Path
      # ---------------------------------------------------------------------

      # 
      # Find and return the page for the given route.
      # 
      def path_for_file file
        pn = file.value

        # Is the file's value a recognizable file?
        return pn if File.exist? pn

        # Look in the web server's asset folder.
        pn = File.join( @engine.settings.project_path, 'asset', pn )

        return pn
      end

    end
  end
end
