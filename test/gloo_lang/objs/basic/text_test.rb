require 'test_helper'

class TextTest < BaseEngineTest

  def test_the_typename
    assert_equal 'text', GlooLang::Objs::Text.typename
  end

  def test_the_short_typename
    assert_equal 'txt', GlooLang::Objs::Text.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'text' )
    assert @dic.find_obj( 'txt' )
  end

  def test_setting_the_value
    o = GlooLang::Objs::Text.new @engine
    o.set_value( "line one\nline two" )
    assert_equal "line one\nline two", o.value
  end

  def test_setting_the_line_count
    o = GlooLang::Objs::Text.new @engine
    o.set_value( "line one\nline two\nthree" )
    assert_equal 3, o.line_count
  end

  def test_messages
    msgs = GlooLang::Objs::Text.messages
    assert msgs
    assert msgs.include?( 'edit' )
    assert msgs.include?( 'page' )
  end

end
