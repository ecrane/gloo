require 'test_helper'

class ResponseCodeTest < BaseEngineTest

  def test_response_codes
    assert_equal Gloo::WebSvr::ResponseCode::SUCCESS, 200
    assert_equal Gloo::WebSvr::ResponseCode::FOUND, 302
    assert_equal Gloo::WebSvr::ResponseCode::NOT_FOUND, 404
    assert_equal Gloo::WebSvr::ResponseCode::SERVER_ERR, 500

    assert_equal Gloo::WebSvr::ResponseCode::CODE_200, "Success/OK"
    assert_equal Gloo::WebSvr::ResponseCode::CODE_403, "Forbidden"
    assert_equal Gloo::WebSvr::ResponseCode::CODE_501, "Not Implemented"    
  end

end
