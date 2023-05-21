require 'test_helper'

class ReloadTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'reload', Gloo::Verbs::Reload.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'r!', Gloo::Verbs::Reload.keyword_shortcut
  end

  def test_reloading_all_files
    @engine.parser.run 'load test'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name

    @engine.parser.run 'reload'

    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name
  end

end
