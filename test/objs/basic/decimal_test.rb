require 'test_helper'

class DecimalTest < BaseEngineTest

  def test_the_typename
    assert_equal 'decimal', Gloo::Objs::Decimal.typename
  end

  def test_the_short_typename
    assert_equal 'num', Gloo::Objs::Decimal.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'Decimal' )
    assert @dic.find_obj( 'DEciMAl' )
    assert @dic.find_obj( 'NUM' )
    assert @dic.find_obj( 'num' )
  end

  def test_setting_the_value
    o = Gloo::Objs::Decimal.new @engine
    o.set_value( 3 )
    assert_equal 3.0, o.value
    o.set_value( -13.987 )
    assert_equal( -13.987, o.value )
  end

  def test_messages
    msgs = Gloo::Objs::Decimal.messages
    assert msgs
    assert msgs.include?( 'round' )
    assert msgs.include?( 'unload' )
    assert msgs.include?( 'format' )
  end

  def test_rounding_down
    @engine.parser.run 'create x as decimal : 1.2342'
    @engine.parser.run 'tell x to round'
    x = @engine.heap.root.children.first
    assert_equal 1.0, x.value
  end

  def test_rounding_up
    @engine.parser.run 'create x as decimal : 12.98'
    @engine.parser.run 'tell x to round'
    x = @engine.heap.root.children.first
    assert_equal 13.0, x.value
  end

  def test_int_dec_mult
    @engine.parser.run 'create x as decimal'
    x = @engine.heap.root.children.first

    @engine.parser.run 'put 100 * 0.75 into x'
    assert_equal 75.0, x.value
  end

  def test_format_msg_default
    i = @engine.parser.parse_immediate 'create x as decimal'
    i.run
    i = @engine.parser.parse_immediate "put 1234567.891 into x"
    i.run

    i = @engine.parser.parse_immediate 'tell x to format'
    i.run
    assert_equal '1,234,567.891', @engine.heap.it.value
  end

  def test_format_msg_negative_default
    i = @engine.parser.parse_immediate 'create x as decimal'
    i.run
    i = @engine.parser.parse_immediate "put -1234567.891 into x"
    i.run

    i = @engine.parser.parse_immediate 'tell x to format'
    i.run
    assert_equal '-1,234,567.891', @engine.heap.it.value
  end

  def test_format_msg_with_format_string
    i = @engine.parser.parse_immediate 'create x as decimal'
    i.run
    i = @engine.parser.parse_immediate "put 3.14159 into x"
    i.run

    i = @engine.parser.parse_immediate "tell x to format ('%.2f')"
    i.run
    assert_equal '3.14', @engine.heap.it.value
  end

end
