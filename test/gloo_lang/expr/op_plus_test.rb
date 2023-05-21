require 'test_helper'

class OpPlusTest < BaseEngineTest

  def test_adding_two_numbers
    @engine.parser.run '= 2 + 3'
    assert_equal 5, @engine.heap.it.value
  end

  def test_adding_three_numbers
    @engine.parser.run '= 2 + 3 + 12'
    assert_equal 17, @engine.heap.it.value
  end

  def test_adding_two_numbers_with_default_op
    @engine.parser.run '= 4 3'
    assert_equal 7, @engine.heap.it.value
  end

  def test_adding_two_decimal_numbers
    @engine.parser.run '= 2.1 + 3.4'
    assert_equal 5.5, @engine.heap.it.value
  end

end
