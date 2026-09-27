require 'test_helper'

class ConverterTest < BaseEngineTest

  def test_datetime_conversion
    dt = DateTime.now
    dtstr = dt.strftime( '%Y.%m.%d' )

    val = @engine.converter.convert( dtstr, 'DateTime', nil )
    assert_equal dtstr, val.strftime( '%Y.%m.%d' )
  end

  def test_integer_conversion
    val = @engine.converter.convert( '321', 'Integer', 0 )
    refute @engine.heap.error?
    assert_equal 321, val
  end

  def test_decimal_conversion
    val = @engine.converter.convert( '3.21', 'Decimal', 0.0 )
    refute @engine.heap.error?
    assert_equal 3.21, val
  end

  def test_conversion_exception
    refute @engine.heap.error?
    val = @engine.converter.convert( '321', 'Sasquach', 0 )
    assert @engine.heap.error?
    assert_equal 0, val
  end

  def test_bad_value_warns_with_the_guess
    warnings = capture_warnings do
      assert_equal 0, @engine.converter.convert( 'x', 'Integer', 0 )
      assert_equal 1.5, @engine.converter.convert( '1.5.5', 'Decimal', 0.0 )
      assert_nil @engine.converter.convert( 'notadate', 'Date' )
    end
    assert_equal [ "'x' is not an integer; using 0.",
                   "'1.5.5' is not a decimal number; using 1.5.",
                   "'notadate' is not a date; using no value." ], warnings
    refute @engine.error?
  end

  def test_good_and_blank_values_do_not_warn
    warnings = capture_warnings do
      @engine.converter.convert( ' 42 ', 'Integer', 0 )
      @engine.converter.convert( '', 'Integer', 0 )
      @engine.converter.convert( '1e3', 'Decimal', 0.0 )
      @engine.converter.convert( 'tomorrow', 'Date' )
      @engine.converter.convert( 'noon', 'Time' )
      @engine.converter.convert( '', 'DateTime' )
    end
    assert_empty warnings
  end

end
