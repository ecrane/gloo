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

  def test_inc_dec_mult
    @engine.parser.run 'show 100 * 0.75'
    assert_equal 75.0, @engine.heap.it.value
  end

def test_multiplying_integer_and_decimal_gives_decimal
  @engine.parser.run "show 3 * 1.5"
  assert_equal 4.5, @engine.heap.it.value

  @engine.parser.run "show 1.5 * 3"
  assert_equal 4.5, @engine.heap.it.value
end

  def test_text_is_used_as_a_number
    @engine.parser.run %q{show '3' * 2}
    assert_equal 6, @engine.heap.it.value, %q{'3' * 2}

    @engine.parser.run %q{show 2 * '3'}
    assert_equal 6, @engine.heap.it.value, %q{2 * '3'}

    @engine.parser.run %q{show '1.5' * 2}
    assert_equal 3.0, @engine.heap.it.value, %q{'1.5' * 2}
    refute @engine.error?
  end

  def test_text_that_is_not_a_number_warns_and_is_zero
    warnings = capture_warnings { @engine.parser.run %q{show 'x' * 2} }
    assert_equal 0, @engine.heap.it.value
    assert_equal [ "'x' is not a number; using 0." ], warnings
  end

end
