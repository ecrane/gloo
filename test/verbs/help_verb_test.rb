require 'test_helper'

class HelpVerbTest < BaseEngineTest

  def test_help_verb_builds_a_help_shell
    @engine.start
    assert @engine.running
    v = Gloo::Verbs::Help.new( @engine, nil )
    shell = v.send( :build_shell )
    assert_kind_of Gloo::Docs::HelpShell, shell
  end

  def test_the_keyword
    assert_equal 'help', Gloo::Verbs::Help.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '?', Gloo::Verbs::Help.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Help.doc_data
    assert_equal Gloo::Verbs::Help.keyword, data[:name]
    assert_equal Gloo::Verbs::Help.keyword_shortcut, data[:shortcut]
  end

end
