require 'test_helper'

class ExecuteTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'execute', GlooLang::Verbs::Execute.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'exec', GlooLang::Verbs::Execute.keyword_shortcut
  end

  def test_without_expression
    @engine.parser.run 'execute'
    assert @engine.error?
    assert_equal GlooLang::Verbs::Execute::MISSING_EXPR_ERR, @engine.heap.error.value
  end

end
