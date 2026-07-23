require 'test_helper'

class EvalTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'eval', Gloo::Verbs::Eval.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'noop', Gloo::Verbs::Eval.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Eval.doc_data
    assert_equal Gloo::Verbs::Eval.keyword, data[:name]
    assert_equal Gloo::Verbs::Eval.keyword_shortcut, data[:shortcut]
  end

  def test_eval_str_concat
    v = @engine.parser.parse_immediate 'eval "hello" + "world"'
    v.run
    assert_equal 'helloworld', @engine.heap.it.value
  end

  def test_eval_math
    v = @engine.parser.parse_immediate 'eval 4 + 3'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_eval_equality
    v = @engine.parser.parse_immediate 'eval 3 = 1'
    v.run
    assert_equal false, @engine.heap.it.value

    v = @engine.parser.parse_immediate 'eval 3 = 3'
    v.run
    assert_equal true, @engine.heap.it.value
  end

  def test_eval
    v = @engine.parser.parse_immediate 'eval'
    v.run
    assert_equal true, @engine.heap.it.value

    v = @engine.parser.parse_immediate 'noop'
    v.run
    assert_equal true, @engine.heap.it.value
  end

  def test_eval_with_variable
    v = @engine.parser.parse_immediate 'create x as int'
    v.run
    v = @engine.parser.parse_immediate 'eval x'
    v.run
    assert_equal 0, @engine.heap.it.value

    v = @engine.parser.parse_immediate 'eval x = 0'
    v.run
    assert_equal true, @engine.heap.it.value

  end

end
