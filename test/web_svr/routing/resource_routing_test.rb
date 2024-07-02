require 'test_helper'

class ResourceRouterTest < BaseEngineTest

  def test_is_implicit_create_check
    refute Gloo::WebSvr::Routing::ResourceRouter.is_implicit_create?( 'get', 'create' )
    refute Gloo::WebSvr::Routing::ResourceRouter.is_implicit_create?( 'put', 'create' )
    refute Gloo::WebSvr::Routing::ResourceRouter.is_implicit_create?( 'delete', 'other' )

    refute Gloo::WebSvr::Routing::ResourceRouter.is_implicit_create?( 'post', 'create' )

    assert Gloo::WebSvr::Routing::ResourceRouter.is_implicit_create?( 'post', 'messages' )
    assert Gloo::WebSvr::Routing::ResourceRouter.is_implicit_create?( 'post', 'users' )
  end

end
