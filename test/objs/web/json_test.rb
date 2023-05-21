
require 'test_helper'

class JsonTest < BaseEngineTest

  def test_the_typename
    assert_equal 'json', Gloo::Objs::Json.typename
  end

  def test_the_short_typename
    assert_equal 'json', Gloo::Objs::Json.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'json' )
    assert @dic.find_obj( 'JSON' )
  end

  def test_setting_the_value
    o = Gloo::Objs::Json.new @engine
    o.set_value( '{"title":"JSON data"}' )
    assert_equal '{"title":"JSON data"}', o.value
  end

  def test_messages
    msgs = Gloo::Objs::Json.messages
    assert msgs
    assert msgs.include?( 'get' )
    assert msgs.include?( 'parse' )
    assert msgs.include?( 'pretty' )
  end

  def test_getting_json_value
    o = @engine.parser.parse_immediate "create j as json"
    o.run
    j = @engine.heap.root.children.first
    j.set_value "{\"title\":\"BOO\"}"
    o = @engine.parser.parse_immediate 'tell j to get ("title")'
    o.run
    assert_equal 'BOO', @engine.heap.it.value
  end

end
