require 'test_helper'

class OpMultTest < BaseEngineTest

  def test_multipyling_two_numbers
    @engine.parser.run 'show 5 * 3'
    assert_equal 15, @engine.heap.it.value
  end

  def test_multipyling_three_numbers
    @engine.parser.run 'show 3 * 7 * 2'
    assert_equal 42, @engine.heap.it.value
  end

  def test_multipyling_decimal_numbers
    @engine.parser.run 'show 1.1 * 3'
    assert_equal 3.3, @engine.heap.it.value.round( 1 )
  end

end
