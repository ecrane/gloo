require 'test_helper'

class ConfigTest < BaseEngineTest

  def test_creation
    c = Gloo::WebSvr::Config.new
    assert c
    assert_equal Gloo::WebSvr::Config::HTTP, c.scheme
    assert_equal Gloo::WebSvr::Config::LOCALHOST, c.host
    assert_equal Gloo::WebSvr::Config::PORT_DEFAULT, c.port
  end

  def test_base_url
    c = Gloo::WebSvr::Config.new
    assert c
    assert_equal 'http://localhost:8080', c.base_url
  end

  def test_doc_config
    c = Gloo::WebSvr::Config.doc_config nil
    assert c
    assert_equal Gloo::WebSvr::Config::HTTP, c.scheme
    assert_equal Gloo::WebSvr::Config::LOCALHOST, c.host
    assert_equal Gloo::WebSvr::Config::DOC_PORT_DEFAULT, c.port
    assert_equal 'http://localhost:8087', c.base_url
  end

end
