require 'test_helper'

class ResponseTest < BaseEngineTest

  def test_creation
    o = Gloo::WebSvr::Response.new
    assert o
    assert_equal Gloo::WebSvr::ResponseCode::SUCCESS, o.code
    assert_equal Gloo::WebSvr::Response::HTML_TYPE, o.type
    refute o.data
  end

  def test_adding_content
    o = Gloo::WebSvr::Response.new
    assert o
    assert_equal Gloo::WebSvr::ResponseCode::SUCCESS, o.code
    assert_equal Gloo::WebSvr::Response::HTML_TYPE, o.type
    refute o.data

    o.add 'one '
    o.add 'two '
    o.add 'three'

    assert_equal 'one two three', o.data
  end

  def test_the_header_hash
    o = Gloo::WebSvr::Response.new

    headers = o.headers
    assert headers
    assert_equal 1, headers.count
    assert_equal "text/html", headers[ "Content-Type" ]
  end

  def test_the_result_array
    o = Gloo::WebSvr::Response.new
    assert o
    assert_equal Gloo::WebSvr::ResponseCode::SUCCESS, o.code
    assert_equal Gloo::WebSvr::Response::HTML_TYPE, o.type
    o.add 'one two three'

    assert_equal 'one two three', o.data
    result = o.result
    assert result
    assert_equal 3, result.count
    assert_equal 200, result[0]
    assert_equal 'one two three', result[2]

    headers = result[1]
    assert headers
    assert_equal 1, headers.count
    assert_equal "text/html", headers[ "Content-Type" ]
  end
end
