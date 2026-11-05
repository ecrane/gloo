require 'test_helper'

class TellTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'tell', Gloo::Verbs::Tell.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '->', Gloo::Verbs::Tell.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Tell.doc_data
    assert_equal Gloo::Verbs::Tell.keyword, data[:name]
    assert_equal Gloo::Verbs::Tell.keyword_shortcut, data[:shortcut]
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
    assert_equal Gloo::Core::NotFound.object( 'x.y.z' ), @engine.heap.error.value
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

  def test_tell_it_is_an_error
    @engine.parser.run 'create c as can'
    @engine.parser.run "create c.x as string : 'ex'"
    @engine.parser.run "eval 'abc'"
    @engine.parser.run "tell it to count"
    assert @engine.error?
    assert_includes @engine.heap.error.value, "it isn't an object and can't be sent messages;"
    assert_equal 'abc', @engine.heap.it.value
  end

  # ---------------------------------------------------------------------
  #    A computed object path: ( expr )
  # ---------------------------------------------------------------------

  def test_tell_a_computed_object
    @engine.parser.run 'create n as int : 1'
    @engine.parser.run "create p as string : 'n'"
    @engine.parser.run 'tell ( p ) to inc'
    refute @engine.error?
    assert_equal 2, @engine.heap.root.find_child( 'n' ).value
  end

  def test_tell_a_computed_object_with_message_params
    @engine.parser.run 'create s as string : hello'
    @engine.parser.run "create p as string : 's'"
    @engine.parser.run "tell ( p ) to starts_with? ( 'he' )"
    refute @engine.error?
    assert_equal true, @engine.heap.it.value
  end

  def test_tell_a_missing_computed_object_names_the_worked_out_path
    @engine.parser.run "tell ( 'no.' 'where' ) to run"
    assert_equal "Object 'no.where' was not found.", @engine.heap.error.value
    assert_equal false, @engine.heap.it.value
  end

  def test_tell_a_computed_object_whose_expression_fails
    @engine.parser.run 'create n as int : 1'
    @engine.parser.run 'tell ( no_such_obj ) to inc'
    assert @engine.error?
    refute_includes @engine.heap.error.value, "'('"
    assert_equal 1, @engine.heap.root.find_child( 'n' ).value
  end

end
