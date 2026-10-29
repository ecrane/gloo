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

  def test_break_skips_the_rest_of_the_pass
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'put 2 into bl.skip_on'
    @engine.parser.run 'tell bl.each_line to run'
    assert_equal [ 4, 3 ], passes_and_after
  end

  def test_break_loop_ends_the_loop
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'put 2 into bl.end_on'
    @engine.parser.run 'tell bl.each_line to run'
    assert_equal [ 2, 1 ], passes_and_after
  end

  # ---------------------------------------------------------------------
  #    Each line comes without its line ending
  # ---------------------------------------------------------------------

  def test_lines_have_no_line_ending
    assert_equal '[one][two]', lines_seen( "one\ntwo\n" )
  end

  def test_windows_line_endings_are_removed_too
    assert_equal '[one][two]', lines_seen( "one\r\ntwo\r\n" )
  end

  def test_a_blank_line_is_still_visited_as_empty
    assert_equal '[one][][two]', lines_seen( "one\n\ntwo\n" )
  end

  def test_a_last_line_without_a_line_ending
    assert_equal '[one][two]', lines_seen( "one\ntwo" )
  end

  def test_a_single_line_with_no_line_ending
    assert_equal '[only]', lines_seen( 'only' )
  end

  private

  #
  # Run an each line loop over the given text, and return what its do
  # script saw: each line wrapped in [ ], one after another.
  #
  def lines_seen( text )
    @engine.parser.run 'create seen as string'
    @engine.parser.run 'create for as each'
    @engine.parser.run 'tell for.word to unload'
    @engine.parser.run 'create for.line as string'
    for_obj = @engine.heap.root.find_child( 'for' )
    for_obj.find_child( 'in' ).set_value text
    for_obj.find_child( 'do' ).set_value "put seen + '[' + ^.line + ']' into seen"
    @engine.parser.run 'tell for to run'
    return @engine.heap.root.find_child( 'seen' ).value
  end

  #
  # How many passes the each line loop's do script started, and how many
  # got past its break (see ctrl/break_loops.gloo).
  #
  def passes_and_after
    bl = @engine.heap.root.find_child( 'bl' )
    return bl.find_child( 'passes' ).value, bl.find_child( 'after' ).value
  end

end
