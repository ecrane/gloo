require 'test_helper'

class SaveTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'save', Gloo::Verbs::Save.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'sv', Gloo::Verbs::Save.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Save.doc_data
    assert_equal Gloo::Verbs::Save.keyword, data[:name]
    assert_equal Gloo::Verbs::Save.keyword_shortcut, data[:shortcut]
  end

end
