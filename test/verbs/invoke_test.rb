require 'test_helper'

class InvokeTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'invoke', Gloo::Verbs::Invoke.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '~>', Gloo::Verbs::Invoke.keyword_shortcut
  end

  def test_invoking_function
    @engine.parser.run 'load ctrl/invoke'
    @engine.parser.run 'invoke f'
    assert_equal 7, @engine.heap.it.value
  end

end
