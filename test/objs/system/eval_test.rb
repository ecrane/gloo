require 'test_helper'

class EvalTest < BaseEngineTest

  def test_the_typename
    assert_equal 'eval', Gloo::Objs::Eval.typename
  end

  def test_the_short_typename
    assert_equal 'ruby', Gloo::Objs::Eval.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'eval' )
    assert @dic.find_obj( 'ruby' )
  end

  def test_messages
    msgs = Gloo::Objs::Eval.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Eval.new @engine
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create e as eval'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'e', obj.name
    assert_equal 2, obj.child_count
    assert_equal 'command', obj.children.first.name
    assert_equal 'result', obj.children.last.name
  end

  def test_run_eval
    i = @engine.parser.parse_immediate 'create e as eval'
    i.run
    e = @engine.heap.root.children.last
    i = @engine.parser.parse_immediate 'put "2+1" into e.command'
    i.run
    assert_equal '', e.children.last.value

    i = @engine.parser.parse_immediate 'run e'
    i.run
    assert_equal '3', e.children.last.value
  end

end
