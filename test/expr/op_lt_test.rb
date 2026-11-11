require 'test_helper'

class OpLtTest < BaseEngineTest

  def test_comparing_integers
    @engine.parser.run 'show 2 < 2'
    assert_equal false, @engine.heap.it.value

    @engine.parser.run 'show 2 < 3'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show 3 < 2'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_decimals
    @engine.parser.run 'show 2.1 < 2.1'
    assert_equal false, @engine.heap.it.value

    @engine.parser.run 'show 2.1 < 2.2'
    assert_equal true, @engine.heap.it.value
  end

  def test_comparing_dates
    @engine.parser.run 'create a as date'
    @engine.parser.run "put '2025.01.01' into a"
    @engine.parser.run 'create b as date'
    @engine.parser.run "put '2025.06.01' into b"

    @engine.parser.run 'show a < b'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show b < a'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_times
    @engine.parser.run 'create t1 as time'
    @engine.parser.run "put '09:00:00 am' into t1"
    @engine.parser.run 'create t2 as time'
    @engine.parser.run "put '05:00:00 pm' into t2"

    @engine.parser.run 'show t1 < t2'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show t2 < t1'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_datetimes
    @engine.parser.run 'create dt1 as datetime'
    @engine.parser.run "put '2025.01.01 09:00:00 am' into dt1"
    @engine.parser.run 'create dt2 as datetime'
    @engine.parser.run "put '2025.01.01 05:00:00 pm' into dt2"

    @engine.parser.run 'show dt1 < dt2'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show dt2 < dt1'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_date_to_time_is_false
    @engine.parser.run 'create a as date'
    @engine.parser.run "put '2025.06.01' into a"
    @engine.parser.run 'create t as time'
    @engine.parser.run "put '09:00:00 am' into t"

    @engine.parser.run 'show a < t'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_date_to_integer_is_false
    @engine.parser.run 'create a as date'
    @engine.parser.run "put '2025.06.01' into a"

    @engine.parser.run 'show a < 5'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_integer_and_decimal
    @engine.parser.run "show 1 < 1.5"
    assert_equal true, @engine.heap.it.value, "1 < 1.5"

    @engine.parser.run "show 1.5 < 1"
    assert_equal false, @engine.heap.it.value, "1.5 < 1"

    @engine.parser.run "show 2 < 1.5"
    assert_equal false, @engine.heap.it.value, "2 < 1.5"
  end

  def test_comparing_strings_in_dictionary_order
    @engine.parser.run "show 'abc' < 'abd'"
    assert_equal true, @engine.heap.it.value, "'abc' < 'abd'"

    @engine.parser.run "show 'abd' < 'abc'"
    assert_equal false, @engine.heap.it.value, "'abd' < 'abc'"

    @engine.parser.run "show 'B' < 'a'"
    assert_equal false, @engine.heap.it.value, "'B' < 'a'"

    @engine.parser.run "show 'A' < 'a'"
    assert_equal true, @engine.heap.it.value, "'A' < 'a'"

    @engine.parser.run "show 'apple' < 'Banana'"
    assert_equal true, @engine.heap.it.value, "'apple' < 'Banana'"

    @engine.parser.run "show 'x' < 'x'"
    assert_equal false, @engine.heap.it.value, "'x' < 'x'"
  end

  def test_comparing_a_number_with_text
    @engine.parser.run %q{show '5' < 10}
    assert_equal true, @engine.heap.it.value, %q{'5' < 10}

    @engine.parser.run %q{show 10 < '5'}
    assert_equal false, @engine.heap.it.value, %q{10 < '5'}

    @engine.parser.run %q{show 3 < 'abc'}
    assert_equal true, @engine.heap.it.value, %q{3 < 'abc'}

    @engine.parser.run %q{show 'abc' < 3}
    assert_equal false, @engine.heap.it.value, %q{'abc' < 3}
  end

end
