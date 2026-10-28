require 'test_helper'

class EachChildTest < BaseEngineTest

  def create_for_each_child
    i = @engine.parser.parse_immediate 'create for as each'
    i.run
    i = @engine.parser.parse_immediate 'tell for.word to unload'
    i.run
    i = @engine.parser.parse_immediate 'create for.child as alias'
    i.run

    return @engine.heap.root.children.first
  end

  def test_use_for
    obj = create_for_each_child
    assert obj

    assert Gloo::Objs::EachChild.use_for?( obj )
    refute Gloo::Objs::EachFile.use_for?( obj )
    refute Gloo::Objs::EachLine.use_for?( obj )
    refute Gloo::Objs::EachWord.use_for?( obj )
  end

  def test_getting_group_by_value
    obj = create_for_each_child
    assert obj
    
    iterator = Gloo::Objs::EachChild.new( @engine, obj )
    assert iterator

    group_by_value = iterator.group_by_value(nil)
    assert_nil group_by_value
    refute iterator.has_group_by?

    i = @engine.parser.parse_immediate 'create for.group_by as string'
    i.run

    group_by_value = iterator.group_by_value(nil)
    refute group_by_value
    assert iterator.has_group_by?

    i = @engine.parser.parse_immediate 'put "wow" into for.group_by'
    i.run
    assert iterator.has_group_by?
  end

  def test_break_ends_the_loop
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'tell bl.each_child to run'
    assert_equal [ 2, 1 ], passes_and_after
  end

  def test_break_still_ends_the_open_group
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'tell bl.grouped to run'
    # g1 runs, g2 breaks: group x is opened and closed; group y never starts
    assert_equal '<c>', @engine.heap.root.find_child( 'bl' ).find_child( 'log' ).value
  end

  def test_group_start_sees_the_groups_first_child
    @engine.parser.run 'load ctrl/group_child'
    @engine.parser.run 'tell gc.grouped to run'
    assert_equal 'ac', @engine.heap.root.find_child( 'gc' ).find_child( 'starts' ).value
  end

  def test_group_end_sees_the_groups_last_child
    @engine.parser.run 'load ctrl/group_child'
    @engine.parser.run 'tell gc.grouped to run'
    assert_equal 'bd', @engine.heap.root.find_child( 'gc' ).find_child( 'ends' ).value
  end

  private

  #
  # How many passes the each child loop's do script started, and how many
  # got past its break (see ctrl/break_loops.gloo).
  #
  def passes_and_after
    bl = @engine.heap.root.find_child( 'bl' )
    return bl.find_child( 'passes' ).value, bl.find_child( 'after' ).value
  end

end
