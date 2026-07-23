require 'test_helper'

class UnlessTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'unless', Gloo::Verbs::Unless.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'if!', Gloo::Verbs::Unless.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Unless.doc_data
    assert_equal Gloo::Verbs::Unless.keyword, data[:name]
    assert_equal Gloo::Verbs::Unless.keyword_shortcut, data[:shortcut]
  end

  def test_evals_false
    v = @engine.parser.parse_immediate 'unless false do show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_evals_true
    v = @engine.parser.parse_immediate 'show 2 + 3'
    v.run
    assert_equal 5, @engine.heap.it.value

    v = @engine.parser.parse_immediate 'unless true do show 2 + 5'
    v.run
    assert_equal 5, @engine.heap.it.value
  end

  def test_it_evals_false
    v = @engine.parser.parse_immediate 'show 2 + 5'
    v.run
    v = @engine.parser.parse_immediate 'unless it do show 2 + 1'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_it_evals_true
    v = @engine.parser.parse_immediate 'show 2 - 2'
    v.run
    v = @engine.parser.parse_immediate 'unless it do show 2 + 1'
    v.run
    assert_equal 3, @engine.heap.it.value
  end

  def test_obj_evals
    v = @engine.parser.parse_immediate 'create x as boolean : false'
    v.run
    v = @engine.parser.parse_immediate 'unless x do show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
    v = @engine.parser.parse_immediate 'put true into x'
    v.run
    v = @engine.parser.parse_immediate 'unless x do show 5 - 2'
    v.run
    assert_equal true, @engine.heap.it.value
  end

end
