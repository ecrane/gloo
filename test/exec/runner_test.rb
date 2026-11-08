require 'test_helper'

class RunnerTest < BaseEngineTest

  def test_running_verb
    s = 'show 3 + 4'
    v = @engine.parser.parse_immediate s
    assert v
    Gloo::Exec::Runner.go @engine, v
    assert_equal 7, @engine.heap.it.value
  end

  def test_running_object_at_path
    s = 'create s as script : "show 3 + 4"'
    @engine.parser.run s
    assert_equal 1, @engine.heap.root.child_count

    Gloo::Exec::Runner.run( @engine, 's' )
    assert_equal 7, @engine.heap.it.value
  end

  def test_running_bad_path
    refute @engine.error?
    Gloo::Exec::Runner.run( @engine, 'no.such.script' )
    assert @engine.error?
  end

  def test_verb_stack_pops_even_when_verb_raises
    starting_size = @engine.exec_env.verbs.size
    @engine.parser.run 'throw "boom"'
    assert_equal starting_size, @engine.exec_env.verbs.size
  end

  def test_exception_in_a_script_line_does_not_abort_later_lines
    o = Gloo::Objs::Script.new @engine
    o.set_array_value( [ 'throw "boom"', 'show 3 + 4' ] )

    s = Gloo::Exec::Script.new( @engine, o )
    s.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_a_script_error_is_handled_not_raised
    verb = @engine.parser.parse_immediate 'show 1'
    verb.define_singleton_method( :run ) { raise SyntaxError, 'bad code' }

    handled = nil
    @engine.define_singleton_method( :handle_exception ) { |ex| handled = ex }
    Gloo::Exec::Runner.go @engine, verb
    assert_kind_of SyntaxError, handled
  end

  def test_run_of_a_missing_object_sets_it_false
    @engine.heap.it.set_to 'stale'
    @engine.parser.run 'run no.such.obj'
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
  end

  def test_run_of_an_object_that_cannot_run_sets_it_false
    @engine.parser.run "create s as string : 'hi'"
    @engine.heap.it.set_to 'stale'
    @engine.parser.run 'run s'
    assert @engine.error?
    assert_includes @engine.heap.error.value, 'cannot receive message run'
    assert_equal false, @engine.heap.it.value
  end

  # A script that runs itself with no end is reported once, as an
  # error naming how deep it got, and gloo keeps going.
  def test_runaway_recursion_is_reported_once
    errors = capture_errors { run_runaway 'run rr.again' }
    assert_equal 1, errors.size
    assert_match( /Could not run rr\.again: scripts ran \d+ deep, one inside another \(runaway recursion\?\)\./, errors.first )
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
    @engine.parser.run 'show 2 + 2'
    assert_equal 4, @engine.heap.it.value
  end

  # It unwinds the whole run: no line after a script's own run runs on
  # the way back up.
  def test_runaway_recursion_unwinds_the_whole_run
    run_runaway 'run rr.again'
    assert rr_value( 'n' ) > 100
    assert_equal 0, rr_value( 'after' )
  end

  # on_error runs once, not once per level.
  def test_runaway_recursion_runs_on_error_once
    run_runaway 'run rr.again'
    assert_equal 1, rr_value( 'errors' )
  end

  # It unwinds to the line that started the recursion: that line is
  # abandoned, and the script it's in carries on.
  def test_runaway_recursion_abandons_the_line_that_started_it
    run_runaway 'run rr.starter'
    assert_equal true, rr_value( 'carried_on' )
  end

  # The same when the starting script was run by an event, like on_load.
  def test_runaway_recursion_in_a_script_an_event_ran
    @engine.parser.run 'load exec/runaway'
    starter = @engine.heap.root.find_child( 'rr' ).find_child( 'starter' )
    Gloo::Exec::Script.new( @engine, starter ).run
    assert_equal true, rr_value( 'carried_on' )
  end

  # The recursion starts at the first script that runs again: for two
  # scripts that run each other, the line that ran the first of them.
  def test_recursion_start_is_the_first_script_that_repeats
    env = @engine.exec_env
    %w[ a b c ].each { |n| @engine.parser.run "create #{n} as script" }
    a, b, c = %w[ a b c ].map { |n| @engine.heap.root.find_child( n ) }
    [ a, b, c, b, c ].each { |o| env.scripts.push( Gloo::Exec::Script.new( @engine, o ) ) }
    assert_equal 1, Gloo::Exec::Runner.recursion_start( env )
  ensure
    env.scripts.clear_stack
  end

  def test_scripts_running_each_other_are_caught
    errors = capture_errors { run_runaway 'run rr.ping' }
    assert_equal 1, errors.size
    assert_includes errors.first, 'runaway recursion'
  end

  def test_a_function_invoking_itself_is_caught
    errors = capture_errors { run_runaway 'invoke rr.f' }
    assert_equal 1, errors.size
    assert_includes errors.first, 'runaway recursion'
  end

  # Every run stack is empty again afterwards.
  def test_runaway_recursion_leaves_the_stacks_empty
    run_runaway 'run rr.again'
    env = @engine.exec_env
    assert_equal [ 0, 0, 0, 0 ], [ env.verbs.size, env.actions.size, env.scripts.size, env.here.size ]
    assert_nil env.running_script
  end

  private

  #
  # Load the runaway scripts and run the given command.
  #
  def run_runaway( cmd )
    @engine.parser.run 'load exec/runaway'
    @engine.parser.run cmd
  end

  #
  # A value in the runaway container.
  #
  def rr_value( name )
    return @engine.heap.root.find_child( 'rr' ).find_child( name ).value
  end

end
