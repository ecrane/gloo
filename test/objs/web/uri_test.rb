
require 'test_helper'

class UriTest < BaseEngineTest

  def test_the_typename
    assert_equal 'uri', Gloo::Objs::Uri.typename
  end

  def test_the_short_typename
    assert_equal 'url', Gloo::Objs::Uri.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'URI' )
    assert @dic.find_obj( 'URL' )
  end

  def test_get_scheme
    o = @engine.parser.parse_immediate "create u as uri : http://foo.com/"
    o.run
    u = @engine.heap.root.children.first
    o = @engine.parser.parse_immediate 'tell u to get_scheme'
    o.run
    assert_equal 'http', @engine.heap.it.value
  end

  def test_get_host
    o = @engine.parser.parse_immediate "create u as uri : http://foo.com/"
    o.run
    u = @engine.heap.root.children.first
    o = @engine.parser.parse_immediate 'tell u to get_host'
    o.run
    assert_equal 'foo.com', @engine.heap.it.value
  end

  def test_get_path
    cmd = "create u as uri : http://foo.com/posts?id=123"
    o = @engine.parser.parse_immediate cmd
    o.run
    u = @engine.heap.root.children.first
    o = @engine.parser.parse_immediate 'tell u to get_path'
    o.run
    assert_equal '/posts', @engine.heap.it.value
  end

  def test_get_query
    cmd = "create u as uri : http://foo.com/posts?id=123"
    o = @engine.parser.parse_immediate cmd
    o.run
    u = @engine.heap.root.children.first
    o = @engine.parser.parse_immediate 'tell u to get_query'
    o.run
    assert_equal 'id=123', @engine.heap.it.value
  end

  def test_get_fragment
    cmd = "create u as uri : http://foo.com/posts?id=123#paragrah=2"
    o = @engine.parser.parse_immediate cmd
    o.run
    u = @engine.heap.root.children.first
    o = @engine.parser.parse_immediate 'tell u to get_fragment'
    o.run
    assert_equal 'paragrah=2', @engine.heap.it.value
  end

end
