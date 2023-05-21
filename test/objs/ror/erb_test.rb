require 'test_helper'

class ErbTest < BaseEngineTest

  def test_the_typename
    assert_equal 'erb', Gloo::Objs::Erb.typename
  end

  def test_the_short_typename
    assert_equal 'erb', Gloo::Objs::Erb.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'erb' )
  end

  def test_messages
    msgs = Gloo::Objs::Erb.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Eval.new @engine
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create e as erb'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'e', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'template', obj.children.first.name
    assert_equal 'params', obj.children[ 1 ].name
    assert_equal 'result', obj.children.last.name
  end

  def test_run_eval
    i = @engine.parser.parse_immediate 'create e as erb'
    i.run
    obj = @engine.heap.root.children.first
    i = @engine.parser.parse_immediate 'put "<%= s %>" into e.template'
    i.run
    i = @engine.parser.parse_immediate 'create e.params.s as string'
    i.run
    i = @engine.parser.parse_immediate 'put "wow" into e.params.s'
    i.run

    result = obj.children.last
    assert_equal '', result.value
    i = @engine.parser.parse_immediate 'run e'
    i.run
    assert_equal 'wow', result.value
  end

end
