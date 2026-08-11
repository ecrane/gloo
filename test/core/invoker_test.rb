require 'test_helper'

class InvokerTest < BaseEngineTest

  def test_missing_target_is_an_error
    result = Gloo::Core::Invoker.invoke( @engine, nil, [] )
    assert_nil result
    assert @engine.error?
    assert_equal Gloo::Core::Invoker::NO_TARGET_ERR, @engine.heap.error.value
  end

  def test_blank_target_is_an_error
    result = Gloo::Core::Invoker.invoke( @engine, '  ', [] )
    assert_nil result
    assert @engine.error?
    assert_equal Gloo::Core::Invoker::NO_TARGET_ERR, @engine.heap.error.value
  end

  def test_unresolved_target_is_an_error
    result = Gloo::Core::Invoker.invoke( @engine, 'no.such.function', [] )
    assert_nil result
    assert @engine.error?
    assert_match Gloo::Core::Invoker::NOT_FOUND_ERR, @engine.heap.error.value
  end

  def test_target_that_is_not_a_function_is_an_error
    @engine.parser.run 'load ctrl/invoke'
    result = Gloo::Core::Invoker.invoke( @engine, 'not_a_function', [] )
    assert_nil result
    assert @engine.error?
    assert_match Gloo::Core::Invoker::NOT_FUNCTION_ERR, @engine.heap.error.value
  end

  def test_param_count_mismatch_is_an_error
    @engine.parser.run 'load ctrl/invoke'
    result = Gloo::Core::Invoker.invoke( @engine, 'add', [ '3' ] )
    assert_nil result
    assert @engine.error?
    assert_match Gloo::Core::Invoker::PARAM_COUNT_ERR, @engine.heap.error.value
  end

  def test_successful_invoke
    @engine.parser.run 'load ctrl/invoke'
    result = Gloo::Core::Invoker.invoke( @engine, 'add', [ '3', '4' ] )
    assert_equal 7, result
    assert_equal 7, @engine.heap.it.value
    refute @engine.error?
  end

  def test_evaluate_arg_tokens_evaluates_each_token_singly
    args = Gloo::Core::Invoker.evaluate_arg_tokens( @engine, [ '3', '4' ] )
    assert_equal [ 3, 4 ], args
  end

  def test_evaluate_arg_tokens_with_nil_returns_empty_array
    args = Gloo::Core::Invoker.evaluate_arg_tokens( @engine, nil )
    assert_equal [], args
  end

end
