require 'test_helper'

class ListTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'list', Gloo::Verbs::List.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '.', Gloo::Verbs::List.keyword_shortcut
  end

  def test_determine_target
    assert @engine.running
    i = @engine.parser.parse_immediate 'list'
    target = i.determine_target
    assert_same @engine.heap.context, target

    i = @engine.parser.parse_immediate 'list me'
    target = i.determine_target
    refute_same @engine.heap.context, target
    assert_equal 'me', target.to_s
  end

  def test_help_not_fount
    @engine.parser.run 'list asjdfajkfjekajfe'
    assert @engine.error?
    msg = Gloo::Verbs::List::TARGET_MISSING_ERR
    assert @engine.heap.error.value.start_with? msg
  end

end
