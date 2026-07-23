require 'test_helper'

class IfTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'if', Gloo::Verbs::If.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'if', Gloo::Verbs::If.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::If.doc_data
    assert_equal Gloo::Verbs::If.keyword, data[:name]
    assert_equal Gloo::Verbs::If.keyword_shortcut, data[:shortcut]
  end

  def test_evals_true
    v = @engine.parser.parse_immediate 'if true then show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_it_evals_true
    v = @engine.parser.parse_immediate 'show 2 + 5'
    v.run
    v = @engine.parser.parse_immediate 'if it then show 2 + 1'
    v.run
    assert_equal 3, @engine.heap.it.value
  end

  def test_it_evals_false
    v = @engine.parser.parse_immediate 'show 2 - 2'
    v.run
    v = @engine.parser.parse_immediate 'if it then show 2 + 1'
    v.run
    assert_equal 0, @engine.heap.it.value
  end

  def test_evals_false
    v = @engine.parser.parse_immediate 'show 2 + 3'
    v.run
    assert_equal 5, @engine.heap.it.value

    v = @engine.parser.parse_immediate 'if false then show 2 + 5'
    v.run
    assert_equal 5, @engine.heap.it.value
  end

  def test_obj_evals
    v = @engine.parser.parse_immediate 'create x as boolean : true'
    v.run
    v = @engine.parser.parse_immediate 'if x then show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
    v = @engine.parser.parse_immediate 'put false into x'
    v.run
    v = @engine.parser.parse_immediate 'if x then show 5 - 2'
    v.run
    assert_equal false, @engine.heap.it.value
  end

end
