require 'test_helper'

class IntegerTest < BaseEngineTest

  def test_the_typename
    assert_equal 'integer', GlooLang::Objs::Integer.typename
  end

  def test_the_short_typename
    assert_equal 'int', GlooLang::Objs::Integer.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'integer' )
    assert @dic.find_obj( 'INTEGER' )
    assert @dic.find_obj( 'int' )
    assert @dic.find_obj( 'INT' )
  end

  def test_setting_the_value
    o = GlooLang::Objs::Integer.new @engine
    o.set_value( 3 )
    assert_equal 3, o.value
    o.set_value( '177' )
    assert_equal 177, o.value
    o.set_value( ' 1 ' )
    assert_equal 1, o.value
    o.set_value( -13 )
    assert_equal( -13, o.value )
  end

  def test_messages
    msgs = GlooLang::Objs::Integer.messages
    assert msgs
    assert msgs.include?( 'inc' )
    assert msgs.include?( 'dec' )
    assert msgs.include?( 'unload' )
  end

  def test_inc_msg
    o = GlooLang::Objs::Integer.new @engine
    o.set_value 0
    assert_equal 0, o.value
    assert_equal 1, o.msg_inc
    assert_equal 1, o.value
    assert_equal 1, @engine.heap.it.value
  end

  def test_dec_msg
    o = GlooLang::Objs::Integer.new @engine
    o.set_value 0
    assert_equal 0, o.value
    assert_equal( -1, o.msg_dec )
    assert_equal( -1, o.value )
    assert_equal( -1, @engine.heap.it.value )
  end

end
