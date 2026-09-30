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

  def test_extra_words_warn_and_still_break
    @engine.parser.run 'create s as script'
    script = @engine.heap.root.find_child( 's' )
    script.set_array_value [ 'show 3', 'break now', 'show 4' ]

    warnings = capture_warnings { @engine.parser.run 'run s' }
    assert_equal 1, warnings.size
    assert_includes warnings.first, "break takes no object; ignoring 'now'."
    assert_equal 3, @engine.heap.it.value
  end

end
