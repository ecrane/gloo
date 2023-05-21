require 'test_helper'

class WaitTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'wait', GlooLang::Verbs::Wait.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'w', GlooLang::Verbs::Wait.keyword_shortcut
  end

end
