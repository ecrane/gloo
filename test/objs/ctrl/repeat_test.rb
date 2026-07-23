require 'test_helper'

class RepeatTest < BaseEngineTest

  def test_the_typename
    assert_equal 'repeat', Gloo::Objs::Repeat.typename
  end

  def test_the_short_typename
    assert_equal 'repeat', Gloo::Objs::Repeat.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Repeat.doc_data
    assert_equal Gloo::Objs::Repeat.typename, data[:name]
    assert_equal Gloo::Objs::Repeat.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'repeat' )
    assert @dic.find_obj( 'REPEAT' )
  end

  def test_messages
    msgs = Gloo::Objs::Repeat.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Repeat.new @engine
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create r as repeat'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'r', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'times', obj.children.first.name
    assert_equal 'index', obj.children[ 1 ].name
    assert_equal 'do', obj.children.last.name
  end

  def test_times
    i = @engine.parser.parse_immediate 'create r as repeat'
    i.run
    obj = @engine.heap.root.children.first

    assert_equal 0, obj.times

    i = @engine.parser.parse_immediate 'put 5 into r.times'
    i.run
    assert_equal 5, obj.times
  end

end
