require 'test_helper'

class EachWordTest < BaseEngineTest

  def test_use_for
    i = @engine.parser.parse_immediate 'create for as each'
    i.run

    obj = @engine.heap.root.children.first
    assert obj

    assert Gloo::Objs::EachWord.use_for?( obj )
    refute Gloo::Objs::EachChild.use_for?( obj )
    refute Gloo::Objs::EachFile.use_for?( obj )
    refute Gloo::Objs::EachLine.use_for?( obj )
  end

  def test_break_skips_the_rest_of_the_pass
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'put 2 into bl.skip_on'
    @engine.parser.run 'tell bl.each_word to run'
    assert_equal [ 4, 3 ], passes_and_after
  end

  def test_break_loop_ends_the_loop
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'put 2 into bl.end_on'
    @engine.parser.run 'tell bl.each_word to run'
    assert_equal [ 2, 1 ], passes_and_after
  end

  private

  #
  # How many passes the each word loop's do script started, and how many
  # got past its break (see ctrl/break_loops.gloo).
  #
  def passes_and_after
    bl = @engine.heap.root.find_child( 'bl' )
    return bl.find_child( 'passes' ).value, bl.find_child( 'after' ).value
  end

end
