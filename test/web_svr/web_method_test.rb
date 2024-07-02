require 'test_helper'

class WebMethodTest < BaseEngineTest

  def test_is_get_check
    assert Gloo::WebSvr::WebMethod.is_get?( 'get' )
    assert Gloo::WebSvr::WebMethod.is_get?( 'GET' )
    assert Gloo::WebSvr::WebMethod.is_get?( 'Get' )

    refute Gloo::WebSvr::WebMethod.is_get?( 'git' )
    refute Gloo::WebSvr::WebMethod.is_get?( 'post' )
    refute Gloo::WebSvr::WebMethod.is_get?( 'delete' )
    refute Gloo::WebSvr::WebMethod.is_get?( 'put' )
  end

  def test_is_post_check
    assert Gloo::WebSvr::WebMethod.is_post?( 'post' )
    assert Gloo::WebSvr::WebMethod.is_post?( 'POST' )
    assert Gloo::WebSvr::WebMethod.is_post?( 'poST' )

    refute Gloo::WebSvr::WebMethod.is_post?( 'po' )
    refute Gloo::WebSvr::WebMethod.is_post?( 'get' )
    refute Gloo::WebSvr::WebMethod.is_post?( 'delete' )
    refute Gloo::WebSvr::WebMethod.is_post?( 'put' )
  end

  def test_is_put_check
    assert Gloo::WebSvr::WebMethod.is_put?( 'put' )
    assert Gloo::WebSvr::WebMethod.is_put?( 'PUT' )
    assert Gloo::WebSvr::WebMethod.is_put?( 'Put' )

    refute Gloo::WebSvr::WebMethod.is_put?( 'post' )
    refute Gloo::WebSvr::WebMethod.is_put?( 'get' )
    refute Gloo::WebSvr::WebMethod.is_put?( 'delete' )
    refute Gloo::WebSvr::WebMethod.is_put?( 'putter' )
  end

  def test_is_patch_check
    assert Gloo::WebSvr::WebMethod.is_patch?( 'patch' )
    assert Gloo::WebSvr::WebMethod.is_patch?( 'PATCH' )
    assert Gloo::WebSvr::WebMethod.is_patch?( 'Patch' )

    refute Gloo::WebSvr::WebMethod.is_patch?( 'pat' )
    refute Gloo::WebSvr::WebMethod.is_patch?( 'get' )
    refute Gloo::WebSvr::WebMethod.is_patch?( 'delete' )
    refute Gloo::WebSvr::WebMethod.is_patch?( 'put' )
  end

  def test_is_delete_check
    assert Gloo::WebSvr::WebMethod.is_delete?( 'delete' )
    assert Gloo::WebSvr::WebMethod.is_delete?( 'DELETE' )
    assert Gloo::WebSvr::WebMethod.is_delete?( 'Delete' )

    refute Gloo::WebSvr::WebMethod.is_delete?( 'del' )
    refute Gloo::WebSvr::WebMethod.is_delete?( 'get' )
    refute Gloo::WebSvr::WebMethod.is_delete?( 'post' )
    refute Gloo::WebSvr::WebMethod.is_delete?( 'put' )
  end

end
