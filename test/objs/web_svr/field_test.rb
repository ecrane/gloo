
require 'test_helper'

class FieldTest < BaseEngineTest

  def test_the_typename
    assert_equal 'field', Gloo::Objs::Field.typename
  end

  def test_the_short_typename
    assert_equal 'field', Gloo::Objs::Field.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'field' )
    assert @dic.find_obj( 'FIELD' )
  end

  def test_messages
    msgs = Gloo::Objs::Field.messages
    assert msgs
    assert msgs.include?( 'render' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Field.new @engine
    assert o.add_children_on_create?
  end

  def test_creating_with_children
    o = @engine.parser.parse_immediate "create f as field"
    o.run
    e = @engine.heap.root.children.first
    assert e
    assert e.children.count.positive?

    attr = e.children.first
    assert attr
    assert_equal 'name', attr.name

    attr = e.children.last
    assert attr
    assert_equal 'type', attr.name
    assert_equal 'text', attr.value
  end

end
