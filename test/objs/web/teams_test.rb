require 'test_helper'

class TeamsTest < BaseEngineTest

  def test_the_typename
    assert_equal 'teams', Gloo::Objs::Teams.typename
  end

  def test_the_short_typename
    assert_equal 'team', Gloo::Objs::Teams.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'teams' )
    assert @dic.find_obj( 'team' )
  end

  def test_messages
    msgs = Gloo::Objs::Teams.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Teams.new @engine
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create t as teams'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 't', obj.name
    assert_equal 4, obj.child_count
    assert_equal 'uri', obj.children.first.name
    assert_equal 'title', obj.children[ 1 ].name
    assert_equal 'color', obj.children[ 2 ].name
    assert_equal 'message', obj.children.last.name
  end

end
