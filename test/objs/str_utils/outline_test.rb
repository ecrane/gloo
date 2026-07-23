require 'test_helper'

class OutlineTest < BaseEngineTest

  def test_the_typename
    assert_equal 'outline', Gloo::Objs::Outline.typename
  end

  def test_the_short_typename
    assert_equal 'outline', Gloo::Objs::Outline.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Outline.doc_data
    assert_equal Gloo::Objs::Outline.typename, data[:name]
    assert_equal Gloo::Objs::Outline.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'outline' )
    assert @dic.find_obj( 'OUTLINE' )
  end

  def test_messages
    msgs = Gloo::Objs::Outline.messages
    assert msgs
    assert msgs.include?( 'generate' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Outline.new @engine
    assert o.add_children_on_create?
  end

  def test_creating_with_children
    i = @engine.parser.parse_immediate 'create o as outline'
    i.run
    assert_equal 1, @engine.heap.root.child_count

    o = @engine.heap.root.children.first
    assert o
    assert_equal 4, o.child_count

    names = o.children.map( &:name )
    assert names.include?( 'object_source' )
    assert names.include?( 'entity_path' )
    assert names.include?( 'separator_char' )
    assert names.include?( 'data' )
  end

end
