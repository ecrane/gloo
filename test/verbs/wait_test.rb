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

end
