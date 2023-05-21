require 'test_helper'

class UnloadTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'unload', GlooLang::Verbs::Unload.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'u!', GlooLang::Verbs::Unload.keyword_shortcut
  end

  def test_reloading_all_files
    @engine.parser.run 'load test'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name

    @engine.parser.run 'unload'

    assert_equal 0, @engine.heap.root.child_count
  end

end
