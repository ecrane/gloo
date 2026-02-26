require 'test_helper'

class ErrorTest < BaseEngineTest

  def test_error_constrution
    o = Gloo::Core::Error.new
    assert o
    refute o.value
  end

  def test_setting_error
    o = Gloo::Core::Error.new
    o.set_to 'something'
    assert_equal 'something', o.value
  end

  def test_to_s
    o = Gloo::Core::Error.new
    o.set_to 'other'
    assert_equal 'other', o.to_s
  end

  def test_setting_error_in_heap
    @engine.heap.error.set_to 'boo'
    assert_equal 'boo', @engine.heap.error.to_s
    assert_equal 'boo', @engine.heap.error.value
  end

  def test_that_by_default_error_is_nil
    refute @engine.heap.error.value
  end

  def test_error_after_show
    @engine.parser.run 'show 2 + 5'
    refute @engine.heap.error.value
  end

  def test_command_without_error
    @engine.parser.run 'show 2 + 5'
    refute @engine.heap.error.value
    refute @engine.error?
  end

  def test_command_with_error
    @engine.parser.run 'put x into'
    assert @engine.heap.error.value
    assert @engine.error?
  end

  def test_that_error_is_cleared
    @engine.heap.error.set_to 'error'
    assert @engine.heap.error.value
    assert @engine.error?

    @engine.parser.run 'show 2 + 5'
    refute @engine.heap.error.value
    refute @engine.error?
  end

  def test_clearing_the_error
    @engine.heap.error.set_to 'error'
    assert @engine.heap.error.value
    assert @engine.error?

    @engine.heap.error.clear
    refute @engine.heap.error.value
    refute @engine.error?
  end

  def test_run_eval_with_error
    i = @engine.parser.parse_immediate 'put x into y'
    i.run
    assert @engine.error?
  end

  def test_error_string
    @engine.heap.error.set_to 'err string'
    refute @engine.heap.it.value
    v = @engine.parser.parse_immediate 'show error'
    v.run
    assert_equal 'err string', @engine.heap.it.value
  end

end
