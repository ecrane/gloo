require 'test_helper'

class LoadTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'load', Gloo::Verbs::Load.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'ld', Gloo::Verbs::Load.keyword_shortcut
  end

  def test_file_load
    assert_equal 0, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate 'load test'
    i.run
    assert_equal 1, @engine.heap.root.child_count
  end

  def test_file_load_with_opt
    assert_equal 0, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate 'load file test'
    i.run
    assert_equal 1, @engine.heap.root.child_count
  end

  def test_file_load_multiline_script
    assert_equal 0, @engine.heap.root.child_count
    i = @engine.parser.parse_immediate 'load script'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 5, @engine.heap.it.value
  end

  def test_load_without_expression
    @engine.parser.run 'load'
    assert @engine.error?
    assert_equal Gloo::Verbs::Load::WRONG_NUM_ARGS_ERR, @engine.heap.error.value
  end

end
