require 'test_helper'

class RequestParamsTest < BaseEngineTest

  def test_creation
    o = Gloo::WebSvr::RequestParams.new( nil )
    assert o
  end

end
