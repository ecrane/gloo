require 'test_helper'

class WaitTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'wait', Gloo::Verbs::Wait.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'w', Gloo::Verbs::Wait.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Wait.doc_data
    assert_equal Gloo::Verbs::Wait.keyword, data[:name]
    assert_equal Gloo::Verbs::Wait.keyword_shortcut, data[:shortcut]
  end

  # Use 0 so the tests don't actually pause.

  def test_waits_for_a_literal_number_of_seconds
    v = @engine.parser.parse_immediate 'wait 0'
    v.run
    refute @engine.error?
  end

  def test_evaluates_its_argument_as_an_expression
    @engine.parser.run 'create secs as int : 0'
    v = @engine.parser.parse_immediate 'wait secs'
    v.run
    refute @engine.error?
  end

  def test_non_numeric_argument_is_treated_as_zero
    v = @engine.parser.parse_immediate 'wait "soon"'
    started = Time.now
    v.run
    assert_operator Time.now - started, :<, 1
    refute @engine.error?
  end

end
