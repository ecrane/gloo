require 'test_helper'

class UntilTest < BaseEngineTest

  def test_the_typename
    assert_equal 'until', Gloo::Objs::Until.typename
  end

  def test_the_short_typename
    assert_equal 'until', Gloo::Objs::Until.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Until.doc_data
    assert_equal Gloo::Objs::Until.typename, data[:name]
    assert_equal Gloo::Objs::Until.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'until' )
    assert @dic.find_obj( 'UNTIL' )
  end

  def test_messages
    msgs = Gloo::Objs::Until.messages
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  # Interactive create adds just do and done; index and max are optional.
  def test_that_do_and_done_are_added_on_create
    @engine.parser.run 'create u as until'
    obj = @engine.heap.root.find_child( 'u' )
    assert_equal [ 'do', 'done' ], obj.children.map( &:name )
  end

  def test_runs_until_done_is_true
    run_loop 'plain'
    assert_equal 3, passes
  end

  # done is checked after each pass, so do runs once even when done
  # would already be true.
  def test_do_runs_at_least_once
    run_loop 'by_text', answer: 'true'
    assert_equal 1, passes
  end

  def test_index_counts_passes_from_zero
    run_loop 'capped'
    assert_equal 3, passes
    assert_equal 2, ul.find_child( 'capped' ).find_child( 'index' ).value
    refute @engine.error?
  end

  def test_reaching_max_is_an_error_and_it_is_false
    errors = capture_errors { run_loop 'capped', stop_at: 10 }
    assert_equal 4, passes
    assert_equal [ "Could not finish until loop ul.capped: done wasn't true after 4 passes." ],
                 errors.map { |e| e.sub( /\A.*?: (?=Could)/, '' ) }
    assert_equal false, @engine.heap.it.value
  end

  def test_a_max_of_zero_is_no_limit
    run_loop 'zero_max', stop_at: 7
    assert_equal 7, passes
    refute @engine.error?
  end

  # done's result follows the [bool] rule: the text t is true.
  def test_the_text_t_ends_the_loop
    run_loop 'by_text', answer: 't'
    assert_equal 1, passes
    refute @engine.error?
  end

  # Other text is false, with a warning, so the loop goes on.
  def test_other_text_goes_on_with_a_warning
    warnings = capture_warnings { run_loop 'by_text', answer: 'abc' }
    assert_equal 3, passes
    assert_includes warnings, "'abc' is not true or false; using false."
  end

  def test_an_error_in_done_ends_the_loop
    run_loop 'bad_done'
    assert @engine.error?
    assert_equal 1, passes
    assert_equal false, @engine.heap.it.value
  end

  def test_an_error_in_do_goes_on
    run_loop 'bad_do'
    assert_equal 3, passes
  end

  def test_no_done_script_is_an_error
    errors = capture_errors { run_loop 'no_done' }
    assert_equal 0, passes
    assert( errors.any? { |e| e.include?( 'Could not run until loop ul.no_done: it has no done script.' ) } )
    assert_equal false, @engine.heap.it.value
  end

  def test_a_blank_done_script_is_an_error
    run_loop 'blank_done'
    assert @engine.error?
    assert_equal 0, passes
  end

  def test_break_skips_the_rest_of_the_pass
    @engine.parser.run 'load ctrl/until_loops'
    @engine.parser.run 'put 2 into ul.skip_on'
    @engine.parser.run 'tell ul.breaks to run'
    assert_equal [ 4, 3 ], [ passes, ul.find_child( 'after' ).value ]
  end

  def test_break_loop_ends_the_loop
    @engine.parser.run 'load ctrl/until_loops'
    @engine.parser.run 'put 2 into ul.end_on'
    @engine.parser.run 'tell ul.breaks to run'
    assert_equal [ 2, 1 ], [ passes, ul.find_child( 'after' ).value ]
    refute @engine.error?
  end

  private

  #
  # Load the until loops, set what done looks for, and run one.
  #
  def run_loop( name, stop_at: 3, answer: '' )
    @engine.parser.run 'load ctrl/until_loops'
    @engine.parser.run "put #{stop_at} into ul.stop_at"
    @engine.parser.run "put '#{answer}' into ul.answer"
    @engine.parser.run "tell ul.#{name} to run"
  end

  #
  # The loops' container.
  #
  def ul
    return @engine.heap.root.find_child( 'ul' )
  end

  #
  # How many passes the loop's do script started.
  #
  def passes
    return ul.find_child( 'passes' ).value
  end

end
