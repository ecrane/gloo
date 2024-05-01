require 'test_helper'

class BreakTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'break', Gloo::Verbs::Break.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'stop', Gloo::Verbs::Break.keyword_shortcut
  end

  def test_running_script
    s = '< ctrl/break'
    @engine.parser.run s
    assert_equal 1, @engine.heap.root.child_count
    @engine.parser.run 'run break'
    assert_equal 3, @engine.heap.it.value
  end

end
