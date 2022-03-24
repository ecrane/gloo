require 'test_helper'

class SystemTest < BaseEngineTest

  def test_the_typename
    assert_equal 'system', Gloo::Objs::System.typename
  end

  def test_the_short_typename
    assert_equal 'sys', Gloo::Objs::System.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'sys' )
    assert @dic.find_obj( 'SYSTEM' )
    assert @dic.find_obj( 'system' )
  end

  def test_messages
    msgs = Gloo::Objs::System.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::System.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create s as sys'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 's', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'command', obj.children.first.name
    assert_equal 'get_output', obj.children[ 1 ].name
    assert_equal 'result', obj.children.last.name
  end

  def test_run_system
    i = @engine.parser.parse_immediate 'create s as sys'
    i.run
    obj = @engine.heap.root.children.first
    i = @engine.parser.parse_immediate 'put "date" into s.command'
    i.run
    assert_equal '', obj.children.last.value

    i = @engine.parser.parse_immediate 'run s'
    i.run
    refute_equal '', obj.children.last.value
  end

  def test_help_text
    assert @engine.help.topic? Gloo::Objs::System.typename
  end

end
