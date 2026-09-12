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

  #
  # 'then' and 'do' are interchangeable separators.
  #
  def test_do_is_a_synonym_for_then
    v = @engine.parser.parse_immediate 'if true do show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_else_runs_when_the_condition_is_false
    v = @engine.parser.parse_immediate 'if false then show 1 else show 2'
    v.run
    assert_equal 2, @engine.heap.it.value
  end

  def test_else_is_skipped_when_the_condition_is_true
    v = @engine.parser.parse_immediate 'if true then show 1 else show 2'
    v.run
    assert_equal 1, @engine.heap.it.value
  end

  def test_else_runs_with_the_do_synonym
    v = @engine.parser.parse_immediate 'if false do show 1 else show 2'
    v.run
    assert_equal 2, @engine.heap.it.value
  end

  #
  # The action's own separator keyword (here, unless's 'do') must not
  # be mistaken for if's -- 'then' is the first separator, so it wins.
  #
  def test_a_nested_unless_in_the_action_does_not_confuse_the_split
    v = @engine.parser.parse_immediate 'create x as boolean : false'
    v.run
    v = @engine.parser.parse_immediate 'if true then unless x do show 9'
    v.run
    assert_equal 9, @engine.heap.it.value
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
