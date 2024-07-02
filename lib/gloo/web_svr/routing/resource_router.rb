# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2024 Eric Crane.  All rights reserved.
#
# A helper class for Resource routing.
# 

module Gloo
  module WebSvr
    module Routing
      class ResourceRouter
        
        INDEX = 'index'.freeze
        SHOW = 'show'.freeze

        POST_ROUTE = 'create'.freeze


        # 
        # Is the given route segment an implicit create resource?
        # It is explicit if it is 'create' 
        #  and implicit if it is a POST to the resource.
        # 
        def self.is_implicit_create?( method, route_segment )
          return false unless Gloo::WebSvr::WebMethod.is_post?( method )

          return ! route_segment.eql?( POST_ROUTE )
        end
   
      end
    end
  end
end