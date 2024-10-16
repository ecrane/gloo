require 'test_helper'

class TellTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'tell', Gloo::Verbs::Tell.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '->', Gloo::Verbs::Tell.keyword_shortcut
  end

  def test_sending_message_with_tell
    o = @engine.parser.parse_immediate 'create s as string'
    o.run
    assert_equal 1, @engine.heap.root.child_count
    o = @engine.parser.parse_immediate 'tell s to unload'
    o.run
    assert_equal 0, @engine.heap.root.child_count
  end

  def test_object_not_found
    @engine.parser.run 'tell x.y.z to run'
    assert @engine.error?
    msg = Gloo::Exec::Dispatch::OBJ_NOT_FOUND_ERR
    assert @engine.heap.error.value.start_with? msg
  end

  def test_unknown_msg
    @engine.parser.run 'tell x.y.z to '
    assert @engine.error?
    assert_equal Gloo::Verbs::Tell::UNKNOWN_MSG_ERR, @engine.heap.error.value
  end

  def test_missing_to
    @engine.parser.run 'tell x.y.z '
    assert @engine.error?
    assert_equal Gloo::Verbs::Tell::UNKNOWN_MSG_ERR, @engine.heap.error.value
  end

  def test_empty_tell
    @engine.parser.run 'tell '
    assert @engine.error?
    assert_equal Gloo::Verbs::Tell::UNKNOWN_MSG_ERR, @engine.heap.error.value
  end

end
