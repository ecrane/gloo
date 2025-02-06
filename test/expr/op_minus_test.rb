require 'test_helper'

class OpMinusTest < BaseEngineTest

  def test_subtracting_two_numbers
    @engine.parser.run 'show 2100 - 2099'
    assert_equal 1, @engine.heap.it.value
  end

  def test_subtracting_three_numbers
    @engine.parser.run 'show 13 - 3 - 3'
    assert_equal 7, @engine.heap.it.value
  end

  def test_subtracting_decimal_numbers
    @engine.parser.run 'show 19.75 - 10.5'
    assert_equal 9.25, @engine.heap.it.value.round( 2 )
  end

end
