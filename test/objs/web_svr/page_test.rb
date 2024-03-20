
require 'test_helper'

class PageTest < BaseEngineTest

  def test_the_typename
    assert_equal 'page', Gloo::Objs::Page.typename
  end

  def test_the_short_typename
    assert_equal 'page', Gloo::Objs::Page.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'page' )
  end

  def test_messages
    msgs = Gloo::Objs::Page.messages
    assert msgs
    assert msgs.include?( 'render' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Page.new @engine
    assert o.add_children_on_create?
  end

  def test_adding_content_type
    o = @engine.parser.parse_immediate "create p as page"
    o.run
    page = @engine.heap.root.children.first
    children_count = page.children.count
    o = @engine.parser.parse_immediate "create p.content_type as string : 'html'"
    o.run

    assert page.children.count > children_count
  end

  def test_page_content_type
    o = @engine.parser.parse_immediate "create p as page"
    o.run
    page = @engine.heap.root.children.first

    assert page
    assert page.is_html?
    refute page.content_type

    o = @engine.parser.parse_immediate "create p.content_type as string : 'html'"
    o.run
    assert page.is_html?
    assert_equal page.content_type, 'html'

    o = @engine.parser.parse_immediate "put 'text' into p.content_type"
    o.run
    refute page.is_html?
    assert page.is_text?
    assert_equal page.content_type, 'text'

    o = @engine.parser.parse_immediate "put 'json' into p.content_type"
    o.run
    refute page.is_html?
    refute page.is_text?
    assert page.is_json?
    assert_equal page.content_type, 'json'
  end

end
