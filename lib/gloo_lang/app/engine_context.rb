# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2022 Eric Crane.  All rights reserved.
#
# The context (parameters) for the Gloo Script Engine.
#

module GlooLang
  module App
    class EngineContext

      attr_accessor :params, :platform, :log, :user_root

      #
      # Create the context, supplying defaults where relevant.
      #
      def initialize( params = [], platform=nil, log=nil, user_root=nil )
        @params = params
        @platform = platform ? platform : Platform.new
        @log = log ? log : Log
        @user_root = user_root
      end

    end
  end
end
