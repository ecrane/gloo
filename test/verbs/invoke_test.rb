require 'test_helper'

class InvokeTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'invoke', Gloo::Verbs::Invoke.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '~>', Gloo::Verbs::Invoke.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Invoke.doc_data
    assert_equal Gloo::Verbs::Invoke.keyword, data[:name]
    assert_equal Gloo::Verbs::Invoke.keyword_shortcut, data[:shortcut]
  end

  def test_invoking_function
    @engine.parser.run 'load ctrl/invoke'
    @engine.parser.run 'invoke f'
    assert_equal 7, @engine.heap.it.value
  end

  def test_invoking_function_with_params
    @engine.parser.run 'load ctrl/invoke'
    @engine.parser.run 'invoke add 3 4'
    assert_equal 7, @engine.heap.it.value
  end

  def test_invoking_with_shortcut
    @engine.parser.run 'load ctrl/invoke'
    @engine.parser.run '~> f'
    assert_equal 7, @engine.heap.it.value
  end

  def test_missing_target_is_an_error
    @engine.parser.run 'invoke'
    assert @engine.error?
    assert_equal Gloo::Core::Invoker::NO_TARGET_ERR, @engine.heap.error.value
  end

  def test_unresolved_target_is_an_error
    @engine.parser.run 'invoke no.such.function'
    assert @engine.error?
    assert_match Gloo::Core::Invoker::NOT_FOUND_ERR, @engine.heap.error.value
  end

  def test_target_that_is_not_a_function_is_an_error
    @engine.parser.run 'load ctrl/invoke'
    @engine.parser.run 'invoke not_a_function'
    assert @engine.error?
    assert_match Gloo::Core::Invoker::NOT_FUNCTION_ERR, @engine.heap.error.value
  end

  def test_too_few_params_is_an_error
    @engine.parser.run 'load ctrl/invoke'
    @engine.parser.run 'invoke add 3'
    assert @engine.error?
    assert_match Gloo::Core::Invoker::PARAM_COUNT_ERR, @engine.heap.error.value
  end

  def test_too_many_params_is_an_error
    @engine.parser.run 'load ctrl/invoke'
    @engine.parser.run 'invoke add 3 4 5'
    assert @engine.error?
    assert_match Gloo::Core::Invoker::PARAM_COUNT_ERR, @engine.heap.error.value
  end

  def test_invocation_failure_does_not_set_it
    @engine.parser.run 'load ctrl/invoke'
    @engine.heap.it.set_to 'unchanged'
    @engine.parser.run 'invoke failing'
    assert @engine.error?
    assert_equal 'unchanged', @engine.heap.it.value
  end

end
