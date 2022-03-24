require 'test_helper'

class ClsTest < BaseEngineTest

  def test_the_keyword
    o = Gloo::Verbs::Cls.keyword
    assert_equal 'cls', o
  end

  def test_the_keyword_shortcut
    assert_equal 'cls', Gloo::Verbs::Cls.keyword_shortcut
  end

  def test_help_text
    assert @engine.help.topic? Gloo::Verbs::Cls.keyword
  end

end
