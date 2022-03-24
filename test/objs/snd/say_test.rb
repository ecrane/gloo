require 'test_helper'

class SayTest < BaseEngineTest

  def test_the_typename
    assert_equal 'say', Gloo::Objs::Say.typename
  end

  def test_the_short_typename
    assert_equal 'say', Gloo::Objs::Say.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'SAY' )
    assert @dic.find_obj( 'say' )
  end

  def test_messages
    msgs = Gloo::Objs::Say.messages
    assert msgs
    assert msgs.include?( 'run' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Say.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create s as say'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 's', obj.name
    assert_equal 2, obj.child_count
    assert_equal 'voice', obj.children.first.name
    assert_equal 'message', obj.children[ 1 ].name
  end

  # def test_run_say
  #   i = @engine.parser.parse_immediate 'create s as say'
  #   i.run
  #   # obj = @engine.heap.root.children.first
  #   i = @engine.parser.parse_immediate 'put "running tests" into s.message'
  #   i.run
  #   i = @engine.parser.parse_immediate 'run s'
  #   i.run
  # end

  def test_help_text
    assert @engine.help.topic? Gloo::Objs::Say.typename
  end

end
