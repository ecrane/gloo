require 'test_helper'

class MoveTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'move', GlooLang::Verbs::Move.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'mv', GlooLang::Verbs::Move.keyword_shortcut
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
    assert_equal GlooLang::Verbs::Move::MISSING_DST_ERR, @engine.heap.error.value
  end

  def test_moving_without_dst
    @engine.parser.run 'move a to'
    assert @engine.error?
    assert_equal GlooLang::Verbs::Move::MISSING_DST_ERR, @engine.heap.error.value
  end

  def test_moving_without_object_to_move
    @engine.parser.run 'create can as container'
    @engine.parser.run 'move to can'
    assert @engine.error?
    assert_equal GlooLang::Verbs::Move::MISSING_SRC_ERR, @engine.heap.error.value
  end

  def test_moving_with_bad_src_path
    @engine.parser.run 'create can as container'
    @engine.parser.run 'move x to can'
    assert @engine.error?
    msg = GlooLang::Verbs::Move::MISSING_SRC_OBJ_ERR
    assert @engine.heap.error.value.start_with? msg
  end

  def test_moving_with_bad_dst_path
    @engine.parser.run 'create x as string'
    @engine.parser.run 'move x to cant'
    assert @engine.error?
    msg = GlooLang::Verbs::Move::MISSING_DST_OBJ_ERR
    assert @engine.heap.error.value.start_with? msg
  end

end
