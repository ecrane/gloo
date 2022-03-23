require 'test_helper'

class BarTest < BaseEngineTest

  def test_the_typename
    assert_equal 'bar', Gloo::Objs::Bar.typename
  end

  def test_the_short_typename
    assert_equal 'bar', Gloo::Objs::Bar.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'bar' )
  end

  def test_messages
    msgs = Gloo::Objs::Bar.messages
    assert msgs
    assert msgs.include?( 'advance' )
    assert msgs.include?( 'start' )
    assert msgs.include?( 'stop' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Bar.new
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create o as bar'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 2, obj.child_count
    assert_equal 'name', obj.children.first.name
    assert_equal 'total', obj.children.last.name
  end

  def test_the_total_value
    i = @engine.parser.parse_immediate 'create o as bar'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    t = obj.children.last
    assert_equal 'total', t.name
    assert_equal 100, t.value
  end

  def test_help_text
    assert @engine.help.topic? Gloo::Objs::Bar.typename
  end

end
