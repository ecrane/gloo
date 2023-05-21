require 'test_helper'

class TableTest < BaseEngineTest

  def test_the_typename
    assert_equal 'table', Gloo::Objs::Table.typename
  end

  def test_the_short_typename
    assert_equal 'tbl', Gloo::Objs::Table.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'table' )
    assert @dic.find_obj( 'tbl' )
  end

  def test_messages
    msgs = Gloo::Objs::Table.messages
    assert msgs
    assert msgs.include?( 'show' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Table.new @engine
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create o as tbl'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 2, obj.child_count
    assert_equal 'headers', obj.children.first.name
    assert_equal 'data', obj.children.last.name
  end

end
