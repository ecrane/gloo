require 'test_helper'

class OpGteqTest < BaseEngineTest

  def test_comparing_integers
    @engine.parser.run 'show 2 >= 2'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show 2 >= 3'
    assert_equal false, @engine.heap.it.value

    @engine.parser.run 'show 3 >= 2'
    assert_equal true, @engine.heap.it.value
  end

  def test_comparing_decimals
    @engine.parser.run 'show 2.1 >= 2.1'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show 7.23 >= 2.1'
    assert_equal true, @engine.heap.it.value
    
    @engine.parser.run 'show 2.1 >= 2.2'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_dates
    @engine.parser.run 'create a as date'
    @engine.parser.run "put '2025.01.01' into a"
    @engine.parser.run 'create b as date'
    @engine.parser.run "put '2025.06.01' into b"

    @engine.parser.run 'show b >= a'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show a >= a'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show a >= b'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_datetimes
    @engine.parser.run 'create dt1 as datetime'
    @engine.parser.run "put '2025.01.01 09:00:00 am' into dt1"
    @engine.parser.run 'create dt2 as datetime'
    @engine.parser.run "put '2025.01.01 09:00:00 am' into dt2"

    @engine.parser.run 'show dt1 >= dt2'
    assert_equal true, @engine.heap.it.value
  end

  def test_comparing_date_to_time_is_false
    @engine.parser.run 'create a as date'
    @engine.parser.run "put '2025.06.01' into a"
    @engine.parser.run 'create t as time'
    @engine.parser.run "put '09:00:00 am' into t"

    @engine.parser.run 'show a >= t'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_date_to_integer_is_false
    @engine.parser.run 'create a as date'
    @engine.parser.run "put '2025.06.01' into a"

    @engine.parser.run 'show a >= 5'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_integer_and_decimal
    @engine.parser.run "show 1 >= 1.5"
    assert_equal false, @engine.heap.it.value, "1 >= 1.5"

    @engine.parser.run "show 2 >= 1.5"
    assert_equal true, @engine.heap.it.value, "2 >= 1.5"

    @engine.parser.run "show 1 >= 1.0"
    assert_equal true, @engine.heap.it.value, "1 >= 1.0"
  end

  def test_comparing_strings_in_dictionary_order
    @engine.parser.run "show 'abd' >= 'abc'"
    assert_equal true, @engine.heap.it.value, "'abd' >= 'abc'"

    @engine.parser.run "show 'abc' >= 'abd'"
    assert_equal false, @engine.heap.it.value, "'abc' >= 'abd'"

    @engine.parser.run "show 'b' >= 'A'"
    assert_equal true, @engine.heap.it.value, "'b' >= 'A'"

    @engine.parser.run "show 'A' >= 'a'"
    assert_equal false, @engine.heap.it.value, "'A' >= 'a'"

    @engine.parser.run "show 'x' >= 'x'"
    assert_equal true, @engine.heap.it.value, "'x' >= 'x'"
  end

  def test_comparing_a_number_with_text
    @engine.parser.run %q{show 5 >= '5.0'}
    assert_equal true, @engine.heap.it.value, %q{5 >= '5.0'}

    @engine.parser.run %q{show 5 >= '6'}
    assert_equal false, @engine.heap.it.value, %q{5 >= '6'}

    @engine.parser.run %q{show 'abc' >= 3}
    assert_equal true, @engine.heap.it.value, %q{'abc' >= 3}
  end

end
