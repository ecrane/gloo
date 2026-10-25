require 'test_helper'

class ShowTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'show', Gloo::Verbs::Show.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'print', Gloo::Verbs::Show.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Show.doc_data
    assert_equal Gloo::Verbs::Show.keyword, data[:name]
    assert_equal Gloo::Verbs::Show.keyword_shortcut, data[:shortcut]
  end

  def test_showing_a_string_literal
    v = @engine.parser.parse_immediate 'show "me"'
    v.run
    assert_equal 'me', @engine.heap.it.value
  end

  def test_showing_with_string_concat
    v = @engine.parser.parse_immediate 'show "me" "too"'
    v.run
    assert_equal 'metoo', @engine.heap.it.value
  end

  def test_showing_with_some_math
    v = @engine.parser.parse_immediate 'show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_showing_with_some_math_three_factor
    v = @engine.parser.parse_immediate 'show 3 + 9 + 1'
    v.run
    assert_equal 13, @engine.heap.it.value
  end

  def test_showing_an_object_value
    v = @engine.parser.parse_immediate 'create x : "boo"'
    v.run
    v = @engine.parser.parse_immediate 'show x'
    v.run
    assert_equal 'boo', @engine.heap.it.value
  end

  # ---------------------------------------------------------------------
  #    A failed expression: the partial value is shown, it is false
  # ---------------------------------------------------------------------

  def test_a_missing_object_puts_false_in_it
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'show no_such_obj'
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
  end

  def test_a_failure_part_way_still_shows_the_partial_value
    shown = capture_shown { @engine.parser.run 'show 1 + no_such_obj' }
    assert @engine.error?
    assert_equal [ '1' ], shown
    assert_equal false, @engine.heap.it.value
  end

  def test_a_failure_at_the_start_puts_false_in_it
    @engine.parser.run 'show no_such_obj + 1'
    assert_equal false, @engine.heap.it.value
  end

  def test_a_failed_inline_invoke_puts_false_in_it
    @engine.parser.run 'load ctrl/invoke'
    @engine.parser.run 'show invoke( add 3 )'
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
  end

  # ---------------------------------------------------------------------
  #    A failed color: the value is shown plain, and goes in it
  # ---------------------------------------------------------------------

  def test_a_failed_color_shows_the_value_without_color
    shown = capture_shown { @engine.parser.run "show 'x' (no_such_obj)" }
    assert_equal [ 'x' ], shown
  end

  def test_a_failed_color_puts_the_value_in_it
    @engine.parser.run "show 'x' (no_such_obj)"
    assert_equal 'x', @engine.heap.it.value
  end

  def test_a_failed_color_reports_the_problem_not_a_crash
    exceptions = []
    @engine.define_singleton_method( :handle_exception ) { |ex| exceptions << ex }
    @engine.parser.run "show 'x' (no_such_obj)"
    assert_equal Gloo::Core::NotFound.object( 'no_such_obj' ), @engine.heap.error.value
    assert_empty exceptions, 'expected no Ruby exception (it was nil.to_sym)'
  end

  private

  #
  # Run the block and return what it showed, one entry per show.
  #
  def capture_shown
    shown = []
    @engine.log.define_singleton_method( :show ) { |msg, *_| shown << msg.to_s }
    yield
    return shown
  ensure
    @engine.log.singleton_class.send( :remove_method, :show )
  end

end
