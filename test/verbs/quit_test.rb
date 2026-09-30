require 'test_helper'

class QuitTest < BaseEngineTest

  def test_quit_verb
    @engine.start
    assert @engine.running
    q = Gloo::Verbs::Quit.new( @engine, nil )
    q.run
    refute @engine.running
  end

  def test_the_keyword
    o = Gloo::Verbs::Quit.keyword
    assert_equal 'quit', o
  end

  def test_the_keyword_shortcut
    assert_equal 'q', Gloo::Verbs::Quit.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Quit.doc_data
    assert_equal Gloo::Verbs::Quit.keyword, data[:name]
    assert_equal Gloo::Verbs::Quit.keyword_shortcut, data[:shortcut]
  end

  def test_extra_words_warn_and_still_quit
    @engine.start
    warnings = capture_warnings { @engine.parser.run 'quit now' }
    assert_includes warnings.first, "quit takes no object; ignoring 'now'."
    refute @engine.running
  end

end
