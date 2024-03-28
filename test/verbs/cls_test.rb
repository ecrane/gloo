require 'test_helper'

class ClsTest < BaseEngineTest

  def test_the_keyword
    o = Gloo::Verbs::Cls.keyword
    assert_equal 'clear', o
  end

  def test_the_keyword_shortcut
    assert_equal 'cls', Gloo::Verbs::Cls.keyword_shortcut
  end

end
