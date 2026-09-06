require 'test_helper'

class ReloadTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'reload', Gloo::Verbs::Reload.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'r!', Gloo::Verbs::Reload.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Reload.doc_data
    assert_equal Gloo::Verbs::Reload.keyword, data[:name]
    assert_equal Gloo::Verbs::Reload.keyword_shortcut, data[:shortcut]
  end

  def test_reloading_all_files
    @engine.parser.run 'load test'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name

    @engine.parser.run 'reload'

    assert_equal 0, @engine.heap.root.child_count
  end

  def test_reloading_a_file
    @engine.parser.run 'load test'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name

    @engine.parser.run 'tell test to reload'

    assert_equal 1, @engine.heap.root.child_count
    assert_equal 'test', @engine.heap.root.children.first.name
  end

  def test_reloading_a_file_with_unsaved_changes_warns_but_still_reloads
    @engine.parser.run 'load test'
    @engine.parser.run "put 'not yet saved' into test.msg"

    warnings = []
    @engine.log.define_singleton_method( :warn ) { |msg| warnings << msg }

    @engine.parser.run 'tell test to reload'

    assert warnings.any? { |w| w.include?( 'Reloading will discard unsaved changes' ) }
    # the reload still happened -- the unsaved change is gone
    assert_equal 'Hello from gloo!', @engine.heap.root.find_child( 'test' ).find_child( 'msg' ).value
  end

  def test_reloading_an_unchanged_file_does_not_warn
    @engine.parser.run 'load test'

    warnings = []
    @engine.log.define_singleton_method( :warn ) { |msg| warnings << msg }

    @engine.parser.run 'tell test to reload'

    assert_equal [], warnings
  end

end
