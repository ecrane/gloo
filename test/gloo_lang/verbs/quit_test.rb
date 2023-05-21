require 'test_helper'

class QuitTest < BaseEngineTest

  def test_quit_verb
    @engine.start
    assert @engine.running
    q = GlooLang::Verbs::Quit.new( @engine, nil )
    q.run
    refute @engine.running
  end

  def test_the_keyword
    o = GlooLang::Verbs::Quit.keyword
    assert_equal 'quit', o
  end

  def test_the_keyword_shortcut
    assert_equal 'q', GlooLang::Verbs::Quit.keyword_shortcut
  end

end
