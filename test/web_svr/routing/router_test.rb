require 'test_helper'

class RouterTest < BaseEngineTest

  def test_creation
    o = @engine.parser.parse_immediate "create s as svr"
    o.run
    svr = @engine.heap.root.children.first

    r = Gloo::WebSvr::Routing::Router.new( @engine, svr )
    assert r
  end

  def test_route_segments
    r = Gloo::WebSvr::Routing::Router.new( @engine, nil )
    assert_equal [], r.detect_segments( '' )
    assert_equal ['a'], r.detect_segments( 'a' )
    assert_equal ['a', 'b'], r.detect_segments( 'a/b' )
    assert_equal ['a', 'b', 'c'], r.detect_segments( 'a/b/c' )
  end

  def test_is_root_path
    r = Gloo::WebSvr::Routing::Router.new( @engine, nil )
    r.detect_segments( '' )
    assert r.is_root_path?

    r.detect_segments( 'a' )
    refute r.is_root_path?

    r.detect_segments( 'a/b' )
    refute r.is_root_path?
  end

  def test_next_segment
    r = Gloo::WebSvr::Routing::Router.new( @engine, nil )
    r.detect_segments( '' )
    assert_nil r.next_segment
    assert_equal 0, r.route_segments.count

    r.detect_segments( 'a' )
    assert_equal 'a', r.next_segment
    assert_equal 0, r.route_segments.count

    r.detect_segments( 'a/b' )
    assert_equal 'a', r.next_segment
    assert_equal 1, r.route_segments.count
    assert_equal 'b', r.next_segment
    assert_equal 0, r.route_segments.count

    r.detect_segments( 'a/b/c' )
    assert_equal 'a', r.next_segment
    assert_equal 2, r.route_segments.count
    assert_equal 'b', r.next_segment
    assert_equal 1, r.route_segments.count
    assert_equal 'c', r.next_segment
    assert_equal 0, r.route_segments.count
  end

end
