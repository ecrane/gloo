require 'test_helper'

class TextTest < BaseEngineTest

  def test_the_typename
    assert_equal 'text', Gloo::Objs::Text.typename
  end

  def test_the_short_typename
    assert_equal 'txt', Gloo::Objs::Text.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Text.doc_data
    assert_equal Gloo::Objs::Text.typename, data[:name]
    assert_equal Gloo::Objs::Text.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'text' )
    assert @dic.find_obj( 'txt' )
  end

  def test_setting_the_value
    o = Gloo::Objs::Text.new @engine
    o.set_value( "line one\nline two" )
    assert_equal "line one\nline two", o.value
  end

  def test_setting_the_line_count
    o = Gloo::Objs::Text.new @engine
    o.set_value( "line one\nline two\nthree" )
    assert_equal 3, o.line_count
  end

  def test_up_msg
    o = Gloo::Objs::Text.new @engine
    o.set_value 'hello'
    assert_equal 'HELLO', o.msg_up
    assert_equal 'HELLO', @engine.heap.it.value
  end

  def test_trim_msg
    o = Gloo::Objs::Text.new @engine
    o.set_value "  hello  "
    assert_equal 'hello', o.msg_trim
    assert_equal 'hello', o.value
  end

end
