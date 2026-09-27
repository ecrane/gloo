require 'test_helper'

class OpPlusTest < BaseEngineTest

  def test_adding_two_numbers
    @engine.parser.run 'show 2 + 3'
    assert_equal 5, @engine.heap.it.value
  end

  def test_adding_three_numbers
    @engine.parser.run 'show 2 + 3 + 12'
    assert_equal 17, @engine.heap.it.value
  end

  def test_adding_two_numbers_with_default_op
    @engine.parser.run 'show 4 3'
    assert_equal 7, @engine.heap.it.value
  end

  def test_adding_two_decimal_numbers
    @engine.parser.run 'show 2.1 + 3.4'
    assert_equal 5.5, @engine.heap.it.value
  end

  def test_concatenating_strings
    @engine.parser.run 'show "hello" + " world"'
    assert_equal 'hello world', @engine.heap.it.value
  end

  def test_joining_strings_with_and
    @engine.parser.run 'show "hello" and " " and "world"'
    assert_equal 'hello world', @engine.heap.it.value
  end

  def test_joining_objects_with_and
    @engine.parser.run 'create first as string : "Ada"'
    @engine.parser.run 'create last as string : "Lovelace"'
    @engine.parser.run 'create full as string'
    @engine.parser.run "put first and ' ' and last into full"
    assert_equal 'Ada Lovelace', @engine.heap.root.find_child( 'full' ).value
  end

  def test_adding_numbers_with_and
    @engine.parser.run 'show 2 and 3'
    assert_equal 5, @engine.heap.it.value
  end

  def test_and_is_not_looked_up_as_an_object
    @engine.parser.run 'create and as string : "X"'
    @engine.parser.run 'show "a" and "b"'
    assert_equal 'ab', @engine.heap.it.value
    refute @engine.error?
  end

  def test_joining_strings_with_no_operator
    @engine.parser.run "show 'hello ' 'world'"
    assert_equal 'hello world', @engine.heap.it.value
  end

  def test_joining_several_strings_with_no_operator
    @engine.parser.run "show 'a' 'b' 'c' 'd'"
    assert_equal 'abcd', @engine.heap.it.value
  end

  def test_joining_objects_and_strings_with_no_operator
    @engine.parser.run 'create first as string : "Ada"'
    @engine.parser.run 'create last as string : "Lovelace"'
    @engine.parser.run 'create full as string'
    @engine.parser.run "put first ' ' last into full"
    assert_equal 'Ada Lovelace', @engine.heap.root.find_child( 'full' ).value
  end

  def test_mixing_no_operator_with_plus_and_and
    @engine.parser.run "show 'a' 'b' + 'c' and 'd' 'e'"
    assert_equal 'abcde', @engine.heap.it.value
  end

end
