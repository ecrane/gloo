require 'test_helper'

class PromptTest < BaseEngineTest

  def test_the_typename
    assert_equal 'prompt', Gloo::Objs::Prompt.typename
  end

  def test_the_short_typename
    assert_equal 'ask', Gloo::Objs::Prompt.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'prompt' )
    assert @dic.find_obj( 'ask' )
  end

  def test_messages
    msgs = Gloo::Objs::Prompt.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'multiline' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Prompt.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create a as ask'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'a', obj.name
    assert_equal 2, obj.child_count
    assert_equal 'prompt', obj.children.first.name
    assert_equal 'result', obj.children.last.name
  end

end
