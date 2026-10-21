require 'test_helper'

class ContextTest < BaseEngineTest

  def test_showing_the_context
    assert @engine.running
    assert_equal 'root', @engine.heap.context.to_s

    i = @engine.parser.parse_immediate '@'
    i&.run
    assert_equal 'root', @engine.heap.context.to_s
  end

  def test_setting_the_context
    assert @engine.running
    assert_equal 'root', @engine.heap.context.to_s

    i = @engine.parser.parse_immediate '@ bob'
    i&.run
    assert_equal 'bob', @engine.heap.it.to_s
  end

  def test_setting_the_context_back_to_root
    assert @engine.running
    assert_equal 'root', @engine.heap.context.to_s

    @engine.parser.run 'context bob'
    assert_equal 'bob', @engine.heap.it.to_s

    @engine.parser.run 'context root'
    assert_equal 'root', @engine.heap.it.to_s
  end

  def test_setting_the_context_to_a_computed_path
    @engine.parser.run 'create p as string : bob'
    @engine.parser.run 'context ( p )'
    refute @engine.error?
    assert_equal 'bob', @engine.heap.context.to_s
    assert_equal 'bob', @engine.heap.it.to_s
  end

  def test_setting_the_context_to_a_computed_path_with_implicit_concat
    @engine.parser.run 'create p as string : bob'
    @engine.parser.run "context ( p '.sub' )"
    refute @engine.error?
    assert_equal 'bob.sub', @engine.heap.context.to_s
  end

  def test_setting_the_context_from_an_unknown_object_is_an_error
    @engine.parser.run 'context ( no_such_obj )'
    assert @engine.error?
    assert_equal 'root', @engine.heap.context.to_s
  end

  def test_the_keyword
    assert_equal 'context', Gloo::Verbs::Context.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '@', Gloo::Verbs::Context.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Context.doc_data
    assert_equal Gloo::Verbs::Context.keyword, data[:name]
    assert_equal Gloo::Verbs::Context.keyword_shortcut, data[:shortcut]
  end

end
