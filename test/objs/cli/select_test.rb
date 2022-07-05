require 'test_helper'

class SelectTest < BaseEngineTest

  def test_the_typename
    assert_equal 'select', Gloo::Objs::Select.typename
  end

  def test_the_short_typename
    assert_equal 'sel', Gloo::Objs::Select.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'select' )
    assert @dic.find_obj( 'SEL' )
  end

  def test_messages
    msgs = Gloo::Objs::Select.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Select.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create s as sel'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 's', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'prompt', obj.children.first.name
    assert_equal 'options', obj.children[1].name
    assert_equal 'result', obj.children.last.name
  end

end
