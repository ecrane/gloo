require 'test_helper'

class RedirectTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'redirect', Gloo::Verbs::Redirect.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'go', Gloo::Verbs::Redirect.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Redirect.doc_data
    assert_equal Gloo::Verbs::Redirect.keyword, data[:name]
    assert_equal Gloo::Verbs::Redirect.keyword_shortcut, data[:shortcut]
  end

  def test_running_script
    s = 'load ctrl/redirect'
    @engine.parser.run s
    assert_equal 1, @engine.heap.root.child_count
    @engine.parser.run 'run redirect.s'
    assert_equal 3, @engine.heap.it.value
  end

end
