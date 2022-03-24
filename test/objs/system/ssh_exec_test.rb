require 'test_helper'

class SshExecTest < BaseEngineTest

  def test_the_typename
    assert_equal 'ssh_exec', Gloo::Objs::SshExec.typename
  end

  def test_the_short_typename
    assert_equal 'ssh', Gloo::Objs::SshExec.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'ssh' )
    assert @dic.find_obj( 'SSH' )
    assert @dic.find_obj( 'ssh_exec' )
  end

  def test_messages
    msgs = Gloo::Objs::SshExec.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::SshExec.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create o as ssh'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'host', obj.children.first.name
    assert_equal 'cmd', obj.children[ 1 ].name
    assert_equal 'result', obj.children.last.name
  end

  def test_help_text
    assert @engine.help.topic? Gloo::Objs::SshExec.typename
  end

end
