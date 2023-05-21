require 'test_helper'

class MarkdownTest < BaseEngineTest

  def test_the_typename
    assert_equal 'markdown', GlooLang::Objs::Markdown.typename
  end

  def test_the_short_typename
    assert_equal 'md', GlooLang::Objs::Markdown.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'markdown' )
    assert @dic.find_obj( 'MD' )
  end

  def test_messages
    msgs = GlooLang::Objs::Markdown.messages
    assert msgs
    assert msgs.include?( 'show' )
    assert msgs.include?( 'page' )
  end

  def test_adds_children_on_create
    o = GlooLang::Objs::Markdown.new @engine
    refute o.add_children_on_create?
  end

end
