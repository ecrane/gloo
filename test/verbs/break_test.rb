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

  def test_extra_words_warn_and_still_break
    @engine.parser.run 'create s as script'
    script = @engine.heap.root.find_child( 's' )
    script.set_array_value [ 'show 3', 'break now', 'show 4' ]

    warnings = capture_warnings { @engine.parser.run 'run s' }
    assert_equal 1, warnings.size
    assert_includes warnings.first, "break takes no object; ignoring 'now'."
    assert_equal 3, @engine.heap.it.value
  end

  # ---------------------------------------------------------------------
  #    What break ends (see ctrl/break_loops.gloo)
  # ---------------------------------------------------------------------

  def test_break_in_an_inner_loop_ends_only_the_inner_loop
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
