require 'test_helper'

class LogVerbTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'log', Gloo::Verbs::Log.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'log', Gloo::Verbs::Log.keyword_shortcut
  end


end
