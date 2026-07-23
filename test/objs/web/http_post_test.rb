require 'test_helper'

class HttpPostTest < BaseEngineTest

  def test_the_typename
    assert_equal 'http_post', Gloo::Objs::HttpPost.typename
  end

  def test_the_short_typename
    assert_equal 'post', Gloo::Objs::HttpPost.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::HttpPost.doc_data
    assert_equal Gloo::Objs::HttpPost.typename, data[:name]
    assert_equal Gloo::Objs::HttpPost.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'post' )
    assert @dic.find_obj( 'POST' )
    assert @dic.find_obj( 'http_post' )
  end

  def test_messages
    msgs = Gloo::Objs::HttpPost.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::HttpPost.new @engine
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create p as post'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'p', obj.name
    assert_equal 2, obj.child_count
    assert_equal 'uri', obj.children.first.name
    assert_equal 'body', obj.children.last.name
  end

  # def test_running_post
  #   i = @engine.parser.parse_immediate 'create p as post'
  #   i.run
  #   p = @engine.heap.root.children.first

  #   i = @engine.parser.parse_immediate 'create p.result as string'
  #   i.run
  #   result = p.children.last
  #   assert result.value.blank?

  #   i = @engine.parser.parse_immediate "put 'https://ecrane.us/api/v1/test' into p.uri"
  #   i.run
  #   i = @engine.parser.parse_immediate 'run p'
  #   i.run
  #   refute result.value.blank?
  # end

end
