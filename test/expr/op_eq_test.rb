require 'test_helper'

class OpEqTest < BaseEngineTest

  def test_comparing_strings
    @engine.parser.run 'show "a" = "a"'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show "a" = "b"'
    assert_equal false, @engine.heap.it.value

    @engine.parser.run 'show "b" = "a"'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_strings_with_alt_symbol
    @engine.parser.run 'show "a" == "a"'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show "a" == "b"'
    assert_equal false, @engine.heap.it.value

    @engine.parser.run 'show "b" == "a"'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_integers
    @engine.parser.run 'show 2 = 2'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show 2 = 3'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_integers_with_alt_symbol
    @engine.parser.run 'show 2 == 2'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show 2 == 3'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_decimals
    @engine.parser.run 'show 2.1 = 2.1'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show 2.1 = 2.2'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_booleans
    @engine.parser.run 'show true = true'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show false = false'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show true = false'
    assert_equal false, @engine.heap.it.value
  end

end
