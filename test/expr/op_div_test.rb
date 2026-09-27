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

  def test_dividing_by_zero_is_an_error
    [ 'show 1 / 0', 'show 1.5 / 0', 'show 0.0 / 0' ].each do |cmd|
      @engine.heap.error.clear
      @engine.parser.run cmd
      assert_equal Gloo::Expr::Expression::DIVIDE_BY_ZERO_ERR, @engine.heap.error.value, cmd
      assert_nil @engine.heap.it.value, cmd
    end
  end

end
