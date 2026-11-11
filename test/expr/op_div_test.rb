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
    [ 'show 1 / 0', 'show 1 / 0.0', 'show 1.5 / 0', 'show 0.0 / 0' ].each do |cmd|
      @engine.heap.error.clear
      @engine.parser.run cmd
      assert_equal Gloo::Expr::Expression::DIVIDE_BY_ZERO_ERR, @engine.heap.error.value, cmd
      assert_equal false, @engine.heap.it.value, cmd
    end
  end

def test_dividing_integer_by_decimal_gives_decimal
  @engine.parser.run "show 7 / 2.0"
  assert_equal 3.5, @engine.heap.it.value

  @engine.parser.run "show 7.0 / 2"
  assert_equal 3.5, @engine.heap.it.value
end

def test_dividing_two_integers_stays_integer
  @engine.parser.run "show 7 / 2"
  assert_equal 3, @engine.heap.it.value
end

  def test_text_is_used_as_a_number
    @engine.parser.run %q{show '7' / '2'}
    assert_equal 3, @engine.heap.it.value, %q{'7' / '2'}

    @engine.parser.run %q{show '7.0' / 2}
    assert_equal 3.5, @engine.heap.it.value, %q{'7.0' / 2}

    @engine.parser.run %q{show 8 / '2'}
    assert_equal 4, @engine.heap.it.value, %q{8 / '2'}
    refute @engine.error?
  end

  def test_dividing_by_text_that_is_not_a_number_is_division_by_zero
    warnings = capture_warnings { @engine.parser.run %q{show 6 / 'x'} }
    assert_equal [ "'x' is not a number; using 0." ], warnings
    assert_equal Gloo::Expr::Expression::DIVIDE_BY_ZERO_ERR, @engine.heap.error.value
  end

end
