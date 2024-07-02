# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A helper class for Web Methods.
# 

module Gloo
  module WebSvr
    class WebMethod

      GET = 'GET'.freeze
      POST = 'POST'.freeze
      PUT = 'PUT'.freeze
      DELETE = 'DELETE'.freeze
      PATCH = 'PATCH'.freeze
      
      # 
      # Is the method a POST?
      # 
      def self.is_post?( method )
        return method.upcase == POST
      end

      # 
      # Is the method a PUT?
      # 
      def self.is_put?( method )
        return method.upcase == PUT
      end

      # 
      # Is the method a PATCH?
      # 
      def self.is_patch?( method )
        return method.upcase == PATCH
      end

      # 
      # Is the method a DELETE?
      # 
      def self.is_delete?( method )
        return method.upcase == DELETE
      end

    end
  end
end