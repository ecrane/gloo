require 'test_helper'
require 'tmpdir'

class EngineTest < BaseTest

  def test_engine_constrution
    o = Gloo::App::Engine.new( default_context )
    assert o
  end

  def test_that_we_can_start_the_engine
    o = Gloo::App::Engine.new( default_context )
    assert o
    o.start
    assert_equal Gloo::App::Mode::EMBED, o.mode
  end

  def test_that_a_running_engine_has_a_mode
    o = Gloo::App::Engine.new( default_context )
    assert o
    o.start
    assert o.mode
  end

  def test_err_before_start_only_logs
    o = Gloo::App::Engine.new( default_context )
    o.log.quiet = true
    o.err 'something went wrong'
    assert_nil o.heap
  end

  def test_bad_app_mode_before_start_falls_back_to_cli
    context = Gloo::App::EngineContext.new(
      [ '--quiet', '--app' ], nil, nil, default_user_root )
    o = Gloo::App::Engine.new( context )
    assert_equal Gloo::App::Mode::CLI, o.args.detect_mode
  end

  def test_that_the_engine_has_args
    o = Gloo::App::Engine.new( default_context )
    assert o.args
  end

  def test_engine_created_in_code_ignores_host_argv
    with_host_argv( [ 'host_arg.gloo' ] ) do
      o = Gloo::App::Engine.new( default_context )
      assert_empty o.args.files
      o.start
      assert_equal Gloo::App::Mode::EMBED, o.mode
    end
  end

  def test_that_the_running_engine_has_a_parser
    o = Gloo::App::Engine.new( default_context )
    o.start
    assert o.parser
  end

  def test_that_the_running_engine_has_an_object_heap
    o = Gloo::App::Engine.new( default_context )
    o.start
    assert o.heap
  end

  def test_that_the_running_engine_has_an_ext_manager
    o = Gloo::App::Engine.new( default_context )
    o.start
    assert o.ext_manager
  end

  def test_that_engine_has_object_factory
    o = Gloo::App::Engine.new( default_context )
    o.start
    assert o.factory
  end

  def test_that_engine_has_persistence_manager
    o = Gloo::App::Engine.new( default_context )
    o.start
    assert o.persist_man
  end

  def test_that_engine_has_an_execution_environment
    o = Gloo::App::Engine.new( default_context )
    o.start
    assert o.exec_env
  end

  def test_that_engine_has_event_manager
    o = Gloo::App::Engine.new( default_context )
    o.start
    assert o.event_manager
  end

  def test_that_engine_has_converter
    o = Gloo::App::Engine.new( default_context )
    o.start
    assert o.converter
  end

  def test_last_cmd_blank
    o = Gloo::App::Engine.new( default_context )
    o.last_cmd = ''
    assert o.last_cmd_blank?

    o.last_cmd = nil
    assert o.last_cmd_blank?

    o.last_cmd = "  \n \t "
    assert o.last_cmd_blank?

    o.last_cmd = 'quit'
    refute o.last_cmd_blank?

    o.last_cmd = 'show 2 + 5'
    refute o.last_cmd_blank?
  end

  def test_stopping
    o = Gloo::App::Engine.new( default_context )
    refute o.running
    o.start
    assert o.running
    o.stop_running
    refute o.running
  end

  def test_err_sets_heap_error
    o = Gloo::App::Engine.new( default_context )
    o.start

    refute o.error?
    o.err( 'boom' )

    assert o.error?
    assert_equal 'boom', o.heap.error.value
  end

  def test_err_fires_on_error
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.parser.run '` on_error as script : "put true into ^.fired"'
    o.parser.run '` fired as bool : false'

    o.err( 'boom' )

    assert_equal true, o.heap.root.find_child( 'fired' ).value
  end

  def test_err_does_not_recurse_when_handler_is_broken
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.parser.run '` on_error as script : "tell definitely_not_a_real_object to run"'

    # Would raise SystemStackError before the re-entrancy guard was added.
    o.err( 'trigger 1' )
    o.err( 'trigger 2' )
    assert true
  end

  def test_handle_exception_fires_on_exception
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.parser.run '` on_exception as script : "put true into ^.fired"'
    o.parser.run '` fired as bool : false'

    begin
      raise 'boom'
    rescue => ex
      o.handle_exception( ex )
    end

    assert_equal true, o.heap.root.find_child( 'fired' ).value
  end

  def test_handle_exception_does_not_recurse_when_handler_is_broken
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.parser.run '` on_exception as script : "throw \'nested boom\'"'

    # Would raise SystemStackError before the re-entrancy guard was added.
    o.parser.run 'throw "outer boom"'
    o.parser.run 'throw "another"'
    assert true
  end

  def test_handle_exception_does_not_trigger_on_error
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.parser.run '` on_error as script : "put true into ^.fired"'
    o.parser.run '` fired as bool : false'

    begin
      raise 'boom'
    rescue => ex
      o.handle_exception( ex )
    end

    assert_equal false, o.heap.root.find_child( 'fired' ).value
  end

  #
  # App mode's extra CLI parameter is meant for the app's own command
  # handling (a [shell] object's one-shot command) - it must not also
  # be attempted as a file load.
  #
  def test_app_mode_extra_param_is_not_loaded_as_a_file
    Dir.mktmpdir do |root|
      File.write( File.join( root, 'start.gloo' ), "greeting [container] :\n\tmsg [string] : hi\n" )

      o = Gloo::App::Engine.new(
        Gloo::App::EngineContext.new(
          [ '--app', root, '--quiet', 'status' ], nil, nil, default_user_root ) )
      o.start

      refute o.error?
    end
  end

  #
  # In App mode, a supplied command means gloo runs it once and exits
  # rather than dropping into the interactive gloo-language REPL.
  #
  def test_run_skips_interactive_loop_in_single_command_app_mode
    Dir.mktmpdir do |root|
      File.write( File.join( root, 'start.gloo' ), "greeting [container] :\n\tmsg [string] : hi\n" )

      o = Gloo::App::Engine.new(
        Gloo::App::EngineContext.new(
          [ '--app', root, 'status' ], nil, nil, default_user_root ) )

      looped = false
      capture_io do
        o.stub :loop, -> { looped = true } do
          o.start
        end
      end

      refute looped
    end
  end

  #
  # A start_with setting with no path (a bare filename) is resolved
  # against the config directory rather than the project path.
  #
  def test_start_with_bare_name_resolves_against_config_directory
    Dir.mktmpdir do |root|
      user_root = File.join( root, 'gloo' )
      Dir.mkdir( user_root )
      config_path = File.join( user_root, 'config' )
      Dir.mkdir( config_path )
      File.write( File.join( config_path, 'gloo.yml' ), <<~YML )
        gloo:
          project_path:
          start_with: start
          list_indent: 2
          list_levels: 3
          debug: false
          theme: dark
      YML
      File.write( File.join( config_path, 'start.gloo' ),
                  "greeting [container] :\n\tmsg [string] : hi\n" )

      o = Gloo::App::Engine.new(
        Gloo::App::EngineContext.new( [ '--quiet' ], nil, nil, user_root ) )
      o.start
      o.open_start_file

      assert_equal 'greeting', o.heap.root.children.first.name
    end
  end

  #
  # A start_with setting doesn't need the .gloo extension -- it's
  # assumed, whether the setting is a bare name or a full path.
  #
  def test_start_with_assumes_gloo_extension
    Dir.mktmpdir do |root|
      user_root = File.join( root, 'gloo' )
      Dir.mkdir( user_root )
      config_path = File.join( user_root, 'config' )
      Dir.mkdir( config_path )
      File.write( File.join( config_path, 'gloo.yml' ), <<~YML )
        gloo:
          project_path:
          start_with: #{File.join( config_path, 'boot' )}
          list_indent: 2
          list_levels: 3
          debug: false
          theme: dark
      YML
      File.write( File.join( config_path, 'boot.gloo' ),
                  "greeting [container] :\n\tmsg [string] : hi\n" )

      o = Gloo::App::Engine.new(
        Gloo::App::EngineContext.new( [ '--quiet' ], nil, nil, user_root ) )
      o.start
      o.open_start_file

      assert_equal 'greeting', o.heap.root.children.first.name
    end
  end

  def test_on_error_handler_does_not_clear_the_error
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.log.quiet = true
    o.parser.run 'create x as int : 0'
    o.parser.run 'create on_error as script : "put 1 into x"'
    o.parser.run 'tell nope to run'
    assert_equal 1, o.heap.root.find_child( 'x' ).value
    assert o.error?
    assert_equal Gloo::Core::NotFound.object( 'nope' ), o.heap.error.value
  end

  def test_err_is_a_runtime_error
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.log.quiet = true
    o.err 'boom'
    assert_equal Gloo::Core::Error::RUNTIME, o.heap.error.kind
  end

  def test_syntax_err_is_a_syntax_error
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.log.quiet = true
    o.syntax_err 'boom'
    assert o.error?
    assert_equal 'boom', o.heap.error.value
    assert_equal Gloo::Core::Error::SYNTAX, o.heap.error.kind
  end

  def test_on_error_handler_does_not_change_the_kind
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.log.quiet = true
    o.parser.run 'create on_error as script : "tell nope to run"'
    o.parser.run 'nosuchverb'
    assert_equal Gloo::Core::Error::SYNTAX, o.heap.error.kind
  end

  def test_warn_goes_to_stderr
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.log.quiet = false
    out, err = capture_io { o.warn 'careful' }
    assert_equal '', out
    assert_match 'careful', err
  end

  def test_warn_logs_with_the_location_and_is_not_an_error
    o = Gloo::App::Engine.new( default_context )
    o.start
    warnings = []
    o.log.define_singleton_method( :warn ) { |msg| warnings << msg }
    o.exec_env.load_location = 'x.gloo:3'
    o.warn 'careful'
    o.exec_env.load_location = nil
    o.warn 'plain'
    assert_equal [ 'x.gloo:3: careful', 'plain' ], warnings
    refute o.error?
  end

  def test_each_report_is_counted_once
    o = Gloo::App::Engine.new( default_context )
    o.start
    o.log.quiet = true
    o.log.reset_counts

    o.err 'runtime'
    o.syntax_err 'syntax'
    o.log_exception raised( 'raised' )
    o.handle_exception raised( 'unhandled' )
    assert_equal 4, o.log.error_count

    o.warn 'careful'
    o.without_warnings { o.warn 'not logged' }
    assert_equal 1, o.log.warning_count
  end

  def raised( msg )
    raise msg
  rescue RuntimeError => e
    return e
  end

  # ---------------------------------------------------------------------
  #    Test mode exit status
  # ---------------------------------------------------------------------

  def test_run_test_exits_1_when_the_tests_fail
    o = started_engine
    o.stub :run_tests, false do
      e = assert_raises( SystemExit ) { o.run_test }
      assert_equal 1, e.status
    end
  end

  def test_run_test_does_not_exit_when_the_tests_pass
    o = started_engine
    o.stub :run_tests, true do
      o.run_test
    end
  end

  def test_run_test_quits_before_exiting
    o = started_engine
    quit_called = false
    o.define_singleton_method( :quit ) { quit_called = true }
    o.stub :run_tests, false do
      assert_raises( SystemExit ) { o.run_test }
    end
    assert quit_called, 'expected on_quit and the rest of quit to run first'
  end

  def test_run_tests_is_false_when_the_runner_reports_a_failure
    o = started_engine
    with_test_runner( o, -> { false } ) { assert_equal false, o.run_tests }
  end

  def test_run_tests_is_true_when_the_runner_reports_a_pass
    o = started_engine
    with_test_runner( o, -> { true } ) { assert_equal true, o.run_tests }
  end

  def test_run_tests_is_true_for_a_runner_that_does_not_report
    # An older gloo-test returns nothing useful from run.
    o = started_engine
    with_test_runner( o, -> { nil } ) { assert_equal true, o.run_tests }
  end

  def test_run_tests_is_false_when_the_runner_raises
    o = started_engine
    o.log.quiet = true
    with_test_runner( o, -> { raise 'boom' } ) { assert_equal false, o.run_tests }
  end

  # ---------------------------------------------------------------------
  #    Script mode exit status
  # ---------------------------------------------------------------------

  def test_run_failed_after_an_error
    o = started_engine
    o.err 'something went wrong'
    assert o.run_failed?
  end

  def test_run_failed_stays_after_a_later_success
    o = started_engine
    o.err 'something went wrong'
    o.process_cmd 'create n as integer : 1'
    refute o.error?, 'the later command cleared the last error'
    assert o.run_failed?
  end

  def test_run_failed_after_a_syntax_error
    o = started_engine
    o.syntax_err 'could not understand'
    assert o.run_failed?
  end

  def test_run_failed_after_an_exception
    o = started_engine
    o.handle_exception raised( 'boom' )
    assert o.run_failed?
  end

  def test_run_not_failed_after_a_warning
    o = started_engine
    o.warn 'a best guess'
    refute o.run_failed?
  end

  def test_run_not_failed_when_clean
    refute started_engine.run_failed?
  end

  def test_err_before_start_does_not_count_toward_the_run
    o = Gloo::App::Engine.new( default_context )
    o.log.quiet = true
    o.err 'something went wrong'
    assert_equal 0, o.run_error_count
  end

  def test_script_exits_1_for_an_error_then_success
    assert_equal 1, script_exit_status( <<~GLOO )
      a [can] :
        on_load [script] :
          show no.such.object
          put 1 into a.n
        n [int] : 0
    GLOO
  end

  def test_script_exits_1_for_success_then_an_error
    assert_equal 1, script_exit_status( <<~GLOO )
      a [can] :
        on_load [script] :
          put 1 into a.n
          show no.such.object
        n [int] : 0
    GLOO
  end

  def test_script_exits_1_for_an_error_on_error_handled
    assert_equal 1, script_exit_status( <<~GLOO )
      a [can] :
        hits [int] : 0
        on_error [script] : put a.hits + 1 into a.hits
        on_load [script] :
          show no.such.object
          put 1 into a.n
        n [int] : 0
    GLOO
  end

  def test_script_exits_1_for_an_exception
    assert_equal 1, script_exit_status( <<~GLOO )
      a [can] :
        on_load [script] :
          throw 'boom'
          put 1 into a.n
        n [int] : 0
    GLOO
  end

  def test_script_exits_1_for_an_exception_on_exception_handled
    assert_equal 1, script_exit_status( <<~GLOO )
      a [can] :
        hits [int] : 0
        on_exception [script] : put a.hits + 1 into a.hits
        on_load [script] :
          throw 'boom'
          put 1 into a.n
        n [int] : 0
    GLOO
  end

  def test_script_exits_0_with_only_a_warning
    assert_equal 0, script_exit_status( <<~GLOO )
      a [can] :
        n [int] : 0
        on_load [script] : put 'abc' into a.n
    GLOO
  end

  def test_script_exits_0_when_clean
    assert_equal 0, script_exit_status( <<~GLOO )
      a [can] :
        n [int] : 0
        on_load [script] : put 1 into a.n
    GLOO
  end

  #
  # Only Script mode sets an exit status: the run failed, but start
  # returns instead of raising SystemExit (which would fail the test).
  #
  def test_app_mode_does_not_exit_after_an_error
    Dir.mktmpdir do |root|
      File.write( File.join( root, 'start.gloo' ),
        "a [can] :\n  on_load [script] : show no.such.object\n" )
      o = Gloo::App::Engine.new(
        Gloo::App::EngineContext.new(
          [ '--app', root, '--quiet', 'status' ], nil, nil, default_user_root ) )
      capture_io { o.start }
      assert o.run_failed?
    end
  end

  private

  #
  # Run the given gloo source as a file in Script mode, the way
  # `gloo file.gloo` does, and get the exit status it ends with.
  #
  def script_exit_status( source )
    Dir.mktmpdir do |root|
      path = File.join( root, 'run.gloo' )
      File.write( path, source )
      o = Gloo::App::Engine.new(
        Gloo::App::EngineContext.new(
          [ path, '--quiet' ], nil, nil, default_user_root ) )
      capture_io { o.start }
      return 0
    rescue SystemExit => e
      return e.status
    end
  end

  #
  # An engine started in the default (embedded) mode, quiet.
  #
  def started_engine
    o = Gloo::App::Engine.new( default_context )
    o.log.quiet = true
    o.start
    return o
  end

  #
  # Run the block with TestRunner replaced by a fake whose run calls
  # the given proc, and with o's loading of the test library stubbed
  # out. The real TestRunner (if gloo-test is loaded) is put back after.
  #
  def with_test_runner( o, run_proc )
    o.lib_manager.define_singleton_method( :load_lib ) { |*_args| true }
    original = Object.const_defined?( :TestRunner ) ? Object.const_get( :TestRunner ) : nil
    Object.send( :remove_const, :TestRunner ) if original
    fake = Class.new do
      define_method( :initialize ) { |*_args| }
      define_method( :run ) { run_proc.call }
    end
    Object.const_set( :TestRunner, fake )
    yield
  ensure
    Object.send( :remove_const, :TestRunner ) if Object.const_defined?( :TestRunner )
    Object.const_set( :TestRunner, original ) if original
  end

end
