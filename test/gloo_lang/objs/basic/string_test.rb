require 'test_helper'

class StringTest < BaseEngineTest

  def test_the_typename
    assert_equal 'string', GlooLang::Objs::String.typename
  end

  def test_the_short_typename
    assert_equal 'str', GlooLang::Objs::String.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'string' )
    assert @dic.find_obj( 'string' )
    assert @dic.find_obj( 'str' )
    assert @dic.find_obj( 'str' )
  end

  def test_setting_the_value
    o = GlooLang::Objs::String.new @engine
    o.set_value( 'a string' )
    assert_equal 'a string', o.value
    o.set_value( 3 )
    assert_equal '3', o.value
    o.set_value( '177' )
    assert_equal '177', o.value
    o.set_value( ' 1 ' )
    assert_equal ' 1 ', o.value
    o.set_value( -13 )
    assert_equal '-13', o.value
  end

  def test_messages
    msgs = GlooLang::Objs::String.messages
    assert msgs
    assert msgs.include?( 'up' )
    assert msgs.include?( 'down' )
    assert msgs.include?( 'unload' )
  end

  def test_size_msg
    o = GlooLang::Objs::String.new @engine
    o.set_value 'one'
    assert_equal 3, o.msg_size
  end

  def test_up_msg
    o = GlooLang::Objs::String.new @engine
    o.set_value 'test'
    assert_equal 'TEST', o.msg_up
    assert_equal 'TEST', @engine.heap.it.value
  end

  def test_down_msg
    o = GlooLang::Objs::String.new @engine
    o.set_value 'test'
    assert_equal 'test', o.msg_down
    assert_equal 'test', @engine.heap.it.value
  end

end
