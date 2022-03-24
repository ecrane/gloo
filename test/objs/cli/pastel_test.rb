require 'test_helper'

class PastelTest < BaseEngineTest

  def test_the_typename
    assert_equal 'pastel', Gloo::Objs::Pastel.typename
  end

  def test_the_short_typename
    assert_equal 'pastel', Gloo::Objs::Pastel.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'pastel' )
    assert @dic.find_obj( 'Pastel' )
  end

  def test_messages
    msgs = Gloo::Objs::Pastel.messages
    assert msgs
    assert msgs.include?( 'show' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Banner.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create o as pastel'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 2, obj.child_count
    assert_equal 'text', obj.children.first.name
    assert_equal 'color', obj.children.last.name
  end

  def test_help_text
    assert @engine.help.topic? Gloo::Objs::Pastel.typename
  end

end
