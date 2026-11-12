require 'test_helper'

class DecimalTest < BaseEngineTest

  def test_the_typename
    assert_equal 'decimal', Gloo::Objs::Decimal.typename
  end

  def test_the_short_typename
    assert_equal 'num', Gloo::Objs::Decimal.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Decimal.doc_data
    assert_equal Gloo::Objs::Decimal.typename, data[:name]
    assert_equal Gloo::Objs::Decimal.short_typename, data[:shortcut]
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

  def test_a_group_in_message_params
    @engine.parser.run 'create x as decimal : 3.14159'
    @engine.parser.run 'tell x to round ( 1 * ( 1 + 1 ) )'
    assert_equal 3.14, @engine.heap.root.find_child( 'x' ).value
  end

  # Format the value with the given format string; the result.
  def format_with( value, fmt )
    @engine.parser.run 'create x as decimal'
    @engine.parser.run "put #{value} into x"
    @engine.parser.run "tell x to format ( '#{fmt}' )"
    return @engine.heap.it.value
  end

  # Round the value to the given precision; the result.
  def round_to( value, precision )
    @engine.parser.run 'create x as decimal'
    @engine.parser.run "put #{value} into x"
    @engine.parser.run "tell x to round ( #{precision} )"
    return @engine.heap.it.value
  end

  def test_format_rounds_first_as_round_does
    assert_equal '1.01', format_with( 1.005, '%.2f' )
    assert_equal '-1.01', format_with( -1.005, '%.2f' )
    assert_equal '0.13', format_with( 0.125, '%.2f' )
    assert_equal '3', format_with( 2.5, '%.0f' )
    assert_equal '$    1.01', format_with( 1.005, '$%8.2f' )
  end

  def test_format_agrees_with_round
    [ [ 1.005, 2 ], [ 2.675, 2 ], [ 0.125, 2 ], [ 1.0005, 3 ], [ -2.5, 0 ] ].each do |value, precision|
      rounded = round_to( value, precision )
      formatted = format_with( value, "%.#{precision}f" )
      assert_equal format( "%.#{precision}f", rounded ), formatted, "#{value} to #{precision}"
    end
  end

  def test_format_without_a_precision_rounds_to_six
    assert_equal '1.234568', format_with( 1.23456789, '%f' )
  end

  def test_format_other_specs_get_the_value_as_is
    assert_equal '1.2e+03', format_with( 1234.5, '%.1e' )
    assert_equal '1', format_with( 1.005, '%d' )
  end

  def test_round_halves_away_from_zero
    assert_equal 3, round_to( 2.5, 0 )
    assert_equal( -3, round_to( -2.5, 0 ) )
    assert_equal 2.68, round_to( 2.675, 2 )
  end

end
