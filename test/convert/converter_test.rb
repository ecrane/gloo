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

end
