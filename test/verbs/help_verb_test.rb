require 'test_helper'

class HelpVerbTest < BaseEngineTest

  def test_help_verb
    @engine.start
    assert @engine.running
    v = Gloo::Verbs::Help.new( @engine, nil )
    v.run
    assert @engine.running
  end

  def test_the_keyword
    assert_equal 'help', Gloo::Verbs::Help.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '?', Gloo::Verbs::Help.keyword_shortcut
  end

end
