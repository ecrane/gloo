require 'test_helper'

class HttpGetTest < BaseEngineTest

  def test_the_typename
    assert_equal 'http_get', Gloo::Objs::HttpGet.typename
  end

  def test_the_short_typename
    assert_equal 'get', Gloo::Objs::HttpGet.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'get' )
    assert @dic.find_obj( 'GET' )
    assert @dic.find_obj( 'http_get' )
  end

  def test_messages
    msgs = Gloo::Objs::HttpGet.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::HttpGet.new @engine
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create g as get'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'g', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'uri', obj.children.first.name
    assert_equal 'params', obj.children[ 1 ].name
    assert_equal 'result', obj.children.last.name
  end

  # 
  # TODO: re-enable this test when we have a way to mock HTTP requests
  # 
  # def test_running_get
  #   i = @engine.parser.parse_immediate 'create g as get'
  #   i.run
  #   g = @engine.heap.root.children.first
  #   assert_equal 3, g.child_count
  #   result = g.children.last
  #   assert result.value.blank?

  #   i = @engine.parser.parse_immediate "put 'https://ecrane.us/api/v1/test' into g.uri"
  #   i.run
  #   i = @engine.parser.parse_immediate 'run g'
  #   i.run
  #   refute result.value.blank?
  # end

end
