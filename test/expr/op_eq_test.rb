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

  def test_comparing_dates
    @engine.parser.run 'create a as date'
    @engine.parser.run "put '2025.06.01' into a"
    @engine.parser.run 'create b as date'
    @engine.parser.run "put '2025.06.01' into b"
    @engine.parser.run 'create c as date'
    @engine.parser.run "put '2025.01.01' into c"

    @engine.parser.run 'show a = b'
    assert_equal true, @engine.heap.it.value

    @engine.parser.run 'show a = c'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_times
    @engine.parser.run 'create t1 as time'
    @engine.parser.run "put '09:00:00 am' into t1"
    @engine.parser.run 'create t2 as time'
    @engine.parser.run "put '09:00:00 am' into t2"

    @engine.parser.run 'show t1 = t2'
    assert_equal true, @engine.heap.it.value
  end

  def test_comparing_datetimes
    @engine.parser.run 'create dt1 as datetime'
    @engine.parser.run "put '2025.06.01 09:00:00 am' into dt1"
    @engine.parser.run 'create dt2 as datetime'
    @engine.parser.run "put '2025.06.01 09:00:00 am' into dt2"

    @engine.parser.run 'show dt1 = dt2'
    assert_equal true, @engine.heap.it.value
  end

  def test_comparing_date_to_datetime_at_midnight
    @engine.parser.run 'create a as date'
    @engine.parser.run "put '2025.06.01' into a"
    @engine.parser.run 'create dt as datetime'
    @engine.parser.run "put '2025.06.01 12:00:00 am' into dt"

    @engine.parser.run 'show a = dt'
    assert_equal true, @engine.heap.it.value
  end

  def test_comparing_date_to_time_is_false
    @engine.parser.run 'create a as date'
    @engine.parser.run "put '2025.06.01' into a"
    @engine.parser.run 'create t as time'
    @engine.parser.run "put '09:00:00 am' into t"

    @engine.parser.run 'show a = t'
    assert_equal false, @engine.heap.it.value
  end

  def test_comparing_date_to_integer_is_false
    @engine.parser.run 'create a as date'
    @engine.parser.run "put '2025.06.01' into a"

    @engine.parser.run 'show a = 5'
    assert_equal false, @engine.heap.it.value
  end

end
