require 'test_helper'

class LogVerbTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'log', Gloo::Verbs::Log.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'log', Gloo::Verbs::Log.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Log.doc_data
    assert_equal Gloo::Verbs::Log.keyword, data[:name]
    assert_equal Gloo::Verbs::Log.keyword_shortcut, data[:shortcut]
  end

  def test_writing_to_log
    @engine.parser.run 'log "hello from log"'
    assert_equal 'hello from log', @engine.heap.it.value
  end

  def test_clearing_the_log
    @engine.parser.run 'log clear'
    refute @engine.error?
  end

end
