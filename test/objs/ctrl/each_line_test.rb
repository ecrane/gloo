require 'test_helper'

class EachLineTest < BaseEngineTest

  def test_use_for
    i = @engine.parser.parse_immediate 'create for as each'
    i.run
    i = @engine.parser.parse_immediate 'tell for.word to unload'
    i.run
    i = @engine.parser.parse_immediate 'create for.line as string'
    i.run

    obj = @engine.heap.root.children.first
    assert obj

    assert Gloo::Objs::EachLine.use_for?( obj )
    refute Gloo::Objs::EachChild.use_for?( obj )
    refute Gloo::Objs::EachFile.use_for?( obj )
    refute Gloo::Objs::EachWord.use_for?( obj )
  end

  def test_break_ends_the_loop
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'tell bl.each_line to run'
    assert_equal [ 2, 1 ], passes_and_after
  end

  private

  #
  # How many passes the each line loop's do script started, and how many
  # got past its break (see ctrl/break_loops.gloo).
  #
  def passes_and_after
    bl = @engine.heap.root.find_child( 'bl' )
    return bl.find_child( 'passes' ).value, bl.find_child( 'after' ).value
  end

end
