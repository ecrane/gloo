require 'test_helper'

class MenuTest < BaseEngineTest

  def test_the_typename
    assert_equal 'menu', Gloo::Objs::Menu.typename
  end

  def test_the_short_typename
    assert_equal 'menu', Gloo::Objs::Menu.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'menu' )
  end

  def test_messages
    msgs = Gloo::Objs::Menu.messages
    assert msgs
    assert msgs.include?( 'unload' )
    assert msgs.include?( 'run' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Menu.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create o as menu'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 4, obj.child_count
    assert_equal 'prompt', obj.children.first.name
    assert_equal 'items', obj.children[1].name
    assert_equal 'loop', obj.children[2].name
    assert_equal 'default', obj.children.last.name
  end

  def test_the_default_prompt_value
    i = @engine.parser.parse_immediate 'create o as menu'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert obj.loop?
    prompt = obj.children.first
    assert_equal '> ', prompt.value
  end

  def test_the_loop_default_value
    i = @engine.parser.parse_immediate 'create o as menu'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert obj.loop?
    loop = obj.children[2]
    assert_equal 'loop', loop.name
    assert_equal true, loop.value
  end

end
