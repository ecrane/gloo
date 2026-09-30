require 'test_helper'

class MoveTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'move', Gloo::Verbs::Move.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'mv', Gloo::Verbs::Move.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Move.doc_data
    assert_equal Gloo::Verbs::Move.keyword, data[:name]
    assert_equal Gloo::Verbs::Move.keyword_shortcut, data[:shortcut]
  end

  def test_moving_an_object
    o = @engine.parser.parse_immediate 'create s as string'
    o.run
    assert_equal 1, @engine.heap.root.child_count

    s = @engine.heap.root.children.first
    assert_equal 'root', s.parent.name

    can = @engine.parser.parse_immediate 'create can as container'
    can.run
    assert_equal 2, @engine.heap.root.child_count

    o = @engine.parser.parse_immediate 'move s to can'
    o.run
    assert_equal 'can', s.parent.name
    assert_equal 1, @engine.heap.root.child_count
  end

  def test_moving_without_to
    @engine.parser.run 'move a'
    assert @engine.error?
    assert_equal Gloo::Verbs::Move::MISSING_DST_ERR, @engine.heap.error.value
  end

  def test_moving_without_dst
    @engine.parser.run 'move a to'
    assert @engine.error?
    assert_equal Gloo::Verbs::Move::MISSING_DST_ERR, @engine.heap.error.value
  end

  def test_moving_without_object_to_move
    @engine.parser.run 'create can as container'
    @engine.parser.run 'move to can'
    assert @engine.error?
    assert_equal Gloo::Verbs::Move::MISSING_SRC_ERR, @engine.heap.error.value
  end

  def test_moving_with_bad_src_path
    @engine.parser.run 'create can as container'
    @engine.parser.run 'move x to can'
    assert @engine.error?
    assert_equal Gloo::Core::NotFound.object( 'x' ), @engine.heap.error.value
  end

  def test_moving_with_bad_dst_path
    @engine.parser.run 'create x as string'
    @engine.parser.run 'move x to cant'
    assert @engine.error?
    assert_equal Gloo::Core::NotFound.object( 'cant' ), @engine.heap.error.value
  end

  def test_move_it_is_an_error
    @engine.parser.run 'create c as can'
    @engine.parser.run "create c.x as string : 'ex'"
    @engine.parser.run "eval 'abc'"
    @engine.parser.run "move it to c"
    assert @engine.error?
    assert_includes @engine.heap.error.value, "it isn't an object and can't be moved;"
    assert_equal 'abc', @engine.heap.it.value
  end

  def test_move_into_it_is_an_error
    @engine.parser.run 'create c as can'
    @engine.parser.run "create c.x as string : 'ex'"
    @engine.parser.run "eval 'abc'"
    @engine.parser.run "move c.x to it"
    assert @engine.error?
    assert_includes @engine.heap.error.value, "it isn't an object and can't be moved into;"
    assert_equal 'abc', @engine.heap.it.value
  end

end
