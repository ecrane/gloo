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

  def test_the_keyword
    assert_equal 'context', GlooLang::Verbs::Context.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '@', GlooLang::Verbs::Context.keyword_shortcut
  end

end
