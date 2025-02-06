require 'test_helper'

class OpDivTest < BaseEngineTest
  
  def test_dividing_two_numbers
    @engine.parser.run 'show 6 / 3'
    assert_equal 2, @engine.heap.it.value
  end

  def test_dividing_three_numbers
    @engine.parser.run 'show 12 / 3 / 2'
    assert_equal 2, @engine.heap.it.value
  end

  def test_dividing_decimal_numbers
    @engine.parser.run 'show 10.5 / 2'
    assert_equal 5.25, @engine.heap.it.value.round( 2 )
  end

end
