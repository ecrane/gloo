require 'test_helper'

class SaveTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'save', GlooLang::Verbs::Save.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '>', GlooLang::Verbs::Save.keyword_shortcut
  end

end
