require 'test_helper'

class MenuItemTest < BaseEngineTest

  def test_the_typename
    assert_equal 'menu_item', Gloo::Objs::MenuItem.typename
  end

  def test_the_short_typename
    assert_equal 'mitem', Gloo::Objs::MenuItem.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'menu_item' )
    assert @dic.find_obj( 'mitem' )
  end

  def test_messages
    msgs = Gloo::Objs::MenuItem.messages
    assert msgs
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::MenuItem.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create o as menu_item'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'shortcut', obj.children.first.name
    assert_equal 'description', obj.children[1].name
    assert_equal 'do', obj.children.last.name
  end

end
