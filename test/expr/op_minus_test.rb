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

def test_subtracting_integer_and_decimal_gives_decimal
  @engine.parser.run "show 1 - 0.5"
  assert_equal 0.5, @engine.heap.it.value

  @engine.parser.run "show 2.5 - 1"
  assert_equal 1.5, @engine.heap.it.value
end

  def test_text_is_used_as_a_number
    @engine.parser.run %q{show 10 - '4'}
    assert_equal 6, @engine.heap.it.value, %q{10 - '4'}

    @engine.parser.run %q{show '10' - 4}
    assert_equal 6, @engine.heap.it.value, %q{'10' - 4}

    @engine.parser.run %q{show '10' - '4'}
    assert_equal 6, @engine.heap.it.value, %q{'10' - '4'}

    @engine.parser.run %q{show 1 - '0.5'}
    assert_equal 0.5, @engine.heap.it.value, %q{1 - '0.5'}

    @engine.parser.run %q{show 1 - ''}
    assert_equal 1, @engine.heap.it.value, %q{1 - ''}
    refute @engine.error?
  end

  def test_text_that_is_not_a_number_warns_and_is_zero
    warnings = capture_warnings { @engine.parser.run %q{show 1 - 'a'} }
    assert_equal 1, @engine.heap.it.value
    assert_equal [ "'a' is not a number; using 0." ], warnings
  end

end
