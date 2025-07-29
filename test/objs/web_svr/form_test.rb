
require 'test_helper'

class FormTest < BaseEngineTest

  def test_the_typename
    assert_equal 'form', Gloo::Objs::Form.typename
  end

  def test_the_short_typename
    assert_equal 'form', Gloo::Objs::Form.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'form' )
    assert @dic.find_obj( 'FORM' )
  end

  def test_messages
    msgs = Gloo::Objs::Form.messages
    assert msgs
    assert msgs.include?( 'render' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Form.new @engine
    assert o.add_children_on_create?
  end

  def test_creating_with_children
    o = @engine.parser.parse_immediate "create f as form"
    o.run
    e = @engine.heap.root.children.first
    assert e
    assert e.children.count.positive?

    attr = e.children.first
    assert attr
    assert_equal 'name', attr.name

    attr = e.children.second
    assert attr
    assert_equal 'method', attr.name

    attr = e.children.third
    assert attr
    assert_equal 'action', attr.name

    attr = e.children.fourth
    assert attr
    assert_equal 'cancel_path', attr.name

    attr = e.children.last
    assert attr
    assert_equal 'content', attr.name
  end

end
