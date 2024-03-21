require 'test_helper'

class RedirectTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'redirect', Gloo::Verbs::Redirect.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'redirect', Gloo::Verbs::Redirect.keyword_shortcut
  end

end
