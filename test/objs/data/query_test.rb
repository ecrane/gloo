require 'test_helper'

class QueryTest < BaseEngineTest

  def test_the_typename
    assert_equal 'query', Gloo::Objs::Query.typename
  end

  def test_the_short_typename
    assert_equal 'sql', Gloo::Objs::Query.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'query' )
    assert @dic.find_obj( 'SQL' )
    assert @dic.find_obj( 'sql' )
  end

  def test_messages
    msgs = Gloo::Objs::Query.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Query.new @engine
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create o as sql'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'database', obj.children.first.name
    assert_equal 'sql', obj.children[ 1 ].name
    assert_equal 'result', obj.children.last.name
  end

end