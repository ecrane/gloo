require 'test_helper'

class BannerTest < BaseEngineTest

  def test_the_typename
    assert_equal 'banner', Gloo::Objs::Banner.typename
  end

  def test_the_short_typename
    assert_equal 'ban', Gloo::Objs::Banner.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'banner' )
    assert @dic.find_obj( 'BAN' )
  end

  def test_messages
    msgs = Gloo::Objs::Banner.messages
    assert msgs
    assert msgs.include?( 'show' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Banner.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create o as banner'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'text', obj.children.first.name
    assert_equal 'style', obj.children[ 1 ].name
    assert_equal 'color', obj.children.last.name
  end

end
