require 'test_helper'

class UnloadTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'unload', Gloo::Verbs::Unload.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'u!', Gloo::Verbs::Unload.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Unload.doc_data
    assert_equal Gloo::Verbs::Unload.keyword, data[:name]
    assert_equal Gloo::Verbs::Unload.keyword_shortcut, data[:shortcut]
  end

  def test_unloading_all_files
    @engine.parser.run 'load test'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name

    @engine.parser.run 'unload'

    assert_equal 0, @engine.heap.root.child_count
  end

  def test_unloading_a_file
    @engine.parser.run 'load test'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name

    @engine.parser.run 'tell test to unload'

    assert_equal 0, @engine.heap.root.child_count
  end

end
