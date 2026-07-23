require 'test_helper'

class BreakTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'break', Gloo::Verbs::Break.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'stop', Gloo::Verbs::Break.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Break.doc_data
    assert_equal Gloo::Verbs::Break.keyword, data[:name]
    assert_equal Gloo::Verbs::Break.keyword_shortcut, data[:shortcut]
  end

  def test_running_script
    s = 'load ctrl/break'
    @engine.parser.run s
    assert_equal 1, @engine.heap.root.child_count
    @engine.parser.run 'run break'
    assert_equal 3, @engine.heap.it.value
  end

end
