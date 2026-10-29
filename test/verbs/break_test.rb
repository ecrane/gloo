require 'test_helper'

class BreakTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'break', Gloo::Verbs::Break.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'stop', Gloo::Verbs::Break.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Break.doc_data
    assert_equal Gloo::Verbs::Break.keyword, data[:name]
    assert_equal Gloo::Verbs::Break.keyword_shortcut, data[:shortcut]
  end

  def test_running_script
    s = 'load ctrl/break'
    @engine.parser.run s
    assert_equal 1, @engine.heap.root.child_count
    @engine.parser.run 'run break'
    assert_equal 3, @engine.heap.it.value
  end

  def test_an_unknown_word_warns_and_still_breaks
    @engine.parser.run 'create s as script'
    script = @engine.heap.root.find_child( 's' )
    script.set_array_value [ 'show 3', 'break now', 'show 4' ]

    warnings = capture_warnings { @engine.parser.run 'run s' }
    assert_equal 1, warnings.size
    assert_includes warnings.first, "break takes only 'loop'; ignoring 'now'."
    assert_equal 3, @engine.heap.it.value
  end

  def test_break_loop_does_not_warn
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'put 2 into bl.end_on'
    warnings = capture_warnings { @engine.parser.run 'tell bl.rep to run' }
    assert_empty warnings
  end

  def test_extra_words_after_break_loop_warn_and_still_end_the_loop
    @engine.parser.run 'load ctrl/break_loops'
    do_script = @engine.heap.root.find_child( 'bl' ).find_child( 'rep' ).find_child( 'do' )
    do_script.set_array_value [
      'put bl.passes + 1 into bl.passes',
      'if bl.passes = 2 then break loop now',
      'put bl.after + 1 into bl.after' ]

    warnings = capture_warnings { @engine.parser.run 'tell bl.rep to run' }
    assert_equal 1, warnings.size
    assert_includes warnings.first, "ignoring 'now'."
    assert_equal [ 2, 1 ], passes_and_after
  end

  # ---------------------------------------------------------------------
  #    What break ends (see ctrl/break_loops.gloo)
  # ---------------------------------------------------------------------

  def test_break_loop_in_an_inner_loop_ends_only_the_inner_loop
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'tell bl.outer to run'
    # 3 outer passes; each inner loop gets past its break once (index 0)
    assert_equal [ 3, 3 ], passes_and_after
  end

  def test_break_in_a_script_the_do_runs_ends_only_that_script
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'tell bl.via to run'
    # the helper's break doesn't end the via loop or its do script
    assert_equal [ 3, 3 ], passes_and_after
  end

  def test_break_loop_in_a_script_the_do_runs_is_an_error
    @engine.parser.run 'load ctrl/break_loops'
    errors = capture_errors { @engine.parser.run 'tell bl.via_loop to run' }
    assert_equal 1, errors.size
    assert_includes errors.first, 'Could not break loop: not in a loop.'
    # the loop and its do script go on
    assert_equal [ 3, 3 ], passes_and_after
  end

  def test_break_loop_outside_a_loop_is_an_error
    @engine.parser.run 'load ctrl/break_loops'
    errors = capture_errors { @engine.parser.run 'run bl.lone' }
    assert_equal 1, errors.size
    assert_includes errors.first, 'Could not break loop: not in a loop.'
  end

  def test_the_script_that_ran_the_loop_carries_on
    @engine.parser.run 'load ctrl/break_loops'
    @engine.parser.run 'run bl.runner'
    assert_equal 'went on', @engine.heap.root.find_child( 'bl' ).find_child( 'log' ).value
  end

  private

  #
  # How many passes the loop's do script started, and how many got
  # past the point where it may break.
  #
  def passes_and_after
    bl = @engine.heap.root.find_child( 'bl' )
    return bl.find_child( 'passes' ).value, bl.find_child( 'after' ).value
  end

end
