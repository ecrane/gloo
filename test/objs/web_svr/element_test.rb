
require 'test_helper'

class ElementTest < BaseEngineTest

  def test_the_typename
    assert_equal 'element', Gloo::Objs::Element.typename
  end

  def test_the_short_typename
    assert_equal 'e', Gloo::Objs::Element.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'element' )
    assert @dic.find_obj( 'e' )
  end

  def test_messages
    msgs = Gloo::Objs::Element.messages
    assert msgs
    assert msgs.include?( 'render' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Element.new @engine
    assert o.add_children_on_create?
  end

  def test_creating_with_children
    o = @engine.parser.parse_immediate "create e as e"
    o.run
    e = @engine.heap.root.children.first
    assert e
    assert e.children.count.positive?

    attr = e.children.first
    assert attr
    assert_equal 'attributes', attr.name
    assert attr.children.count.positive?
    assert_equal 'id', attr.children.first.name

    assert_equal 'content', e.children.last.name
  end

  def test_tag_from_name
    o = @engine.parser.parse_immediate "create div as e"
    o.run
    e = @engine.heap.root.children.first
    assert_equal 'div', e.tag

    o = @engine.parser.parse_immediate "create div_other as e"
    o.run
    e = @engine.heap.root.children.last
    assert_equal 'div', e.tag
  end

  def test_tag_open
    o = @engine.parser.parse_immediate "create div_3 as e"
    o.run
    e = @engine.heap.root.children.first
    assert_equal '<div>', e.tag_open
  end

  def test_tag_open_with_id
    o = @engine.parser.parse_immediate "create div_3 as e"
    o.run
    o = @engine.parser.parse_immediate "put 123 into div_3.attributes.id"
    o.run
    e = @engine.heap.root.children.first
    assert_equal '<div id="123">', e.tag_open
  end

  def test_tag_close
    o = @engine.parser.parse_immediate "create div as e"
    o.run
    e = @engine.heap.root.children.first
    assert_equal '</div>', e.tag_close
  end

  def test_attribute_hash
    o = @engine.parser.parse_immediate "create div as e"
    o.run
    e = @engine.heap.root.children.first
    
    attr = e.find_child 'attributes'
    assert attr

    id = attr.find_child 'id'
    assert id
    id.value = '123'

    classes = attr.find_child 'classes'
    assert classes
    classes.value = 'one two'

    attr_hash = e.attributes_hash
    assert attr_hash
    assert_equal 2, attr_hash.count
  end
end
