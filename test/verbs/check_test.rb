require 'test_helper'

class CheckTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'check', Gloo::Verbs::Check.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '<-', Gloo::Verbs::Check.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Check.doc_data
    assert_equal Gloo::Verbs::Check.keyword, data[:name]
    assert_equal Gloo::Verbs::Check.keyword_shortcut, data[:shortcut]
  end

  def test_sending_message_with_check
    o = @engine.parser.parse_immediate 'create s as string'
    o.run
    assert_equal 1, @engine.heap.root.child_count
    o = @engine.parser.parse_immediate 'check s for blank?'
    o.run
    assert @engine.heap.it.value
  end

  def test_object_not_found
    @engine.parser.run 'check x.y.z for blank?'
    assert @engine.error?
    msg = Gloo::Exec::Dispatch::OBJ_NOT_FOUND_ERR
    assert @engine.heap.error.value.start_with? msg
  end

  def test_unknown_msg
    @engine.parser.run 'check x.y.z for '
    assert @engine.error?
    assert_equal Gloo::Verbs::Check::UNKNOWN_MSG_ERR, @engine.heap.error.value
  end

  def test_missing_to
    @engine.parser.run 'check x.y.z '
    assert @engine.error?
    assert_equal Gloo::Verbs::Check::UNKNOWN_MSG_ERR, @engine.heap.error.value
  end

  def test_empty_tell
    @engine.parser.run 'check '
    assert @engine.error?
    assert_equal Gloo::Verbs::Check::UNKNOWN_MSG_ERR, @engine.heap.error.value
  end

end
