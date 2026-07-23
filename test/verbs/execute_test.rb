require 'test_helper'

class ExecuteTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'execute', Gloo::Verbs::Execute.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'exec', Gloo::Verbs::Execute.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Execute.doc_data
    assert_equal Gloo::Verbs::Execute.keyword, data[:name]
    assert_equal Gloo::Verbs::Execute.keyword_shortcut, data[:shortcut]
  end

  def test_without_expression
    @engine.parser.run 'execute'
    assert @engine.error?
    assert_equal Gloo::Verbs::Execute::MISSING_EXPR_ERR, @engine.heap.error.value
  end

end
