require 'test_helper'

class LogTest < BaseTest

  # def test_creation
  #   Gloo::App::Engine.new( [ '--quiet' ] )
  #   assert $log
  # end
  #
  # def test_default_logger
  #   Gloo::App::Engine.new( [ '--quiet' ] )
  #   assert $log.logger
  #   assert_equal Logger::DEBUG, $log.logger.level
  # end
  #
  # def test_quiet_logging
  #   Gloo::App::Engine.new( [ '--quiet' ] )
  #   assert $log.quiet
  # end
  #
  # def test_noisy_logging_by_default
  #   Gloo::App::Engine.new
  #   refute $log.quiet
  # end
  #
  # def test_debug
  #   Gloo::App::Engine.new( [ '--quiet' ] )
  #   $log.debug 'debug statement'
  # end
  #
  # def test_info
  #   Gloo::App::Engine.new( [ '--quiet' ] )
  #   $log.info 'info statement'
  # end
  #
  # def test_warn
  #   Gloo::App::Engine.new( [ '--quiet' ] )
  #   $log.warn 'warn statement'
  # end
  #
  # def test_error
  #   Gloo::App::Engine.new( [ '--quiet' ] )
  #   $log.error 'error statement'
  # end

  def test_log_levels_constants
    assert_equal Gloo::App::Log::LEVELS.count, 4
    assert_equal Gloo::App::Log::LEVELS[0], 'debug'
  end

  def test_log_file_name_constants
    assert_equal Gloo::App::Log::LOG_FILE, 'gloo.log'
    assert_equal Gloo::App::Log::ERROR_FILE, 'error.log'
  end

  def test_level_constants
    assert_equal Gloo::App::Log::DEBUG, 'debug'
    assert_equal Gloo::App::Log::INFO, 'info'
    assert_equal Gloo::App::Log::WARN, 'warn'
    assert_equal Gloo::App::Log::ERROR, 'error'
  end

  def test_levels_include
    assert Gloo::App::Log.is_level? 'DEBUG'
    assert Gloo::App::Log.is_level? 'debug'
    assert Gloo::App::Log.is_level? 'deBUG'
    assert Gloo::App::Log.is_level? 'info'
    assert Gloo::App::Log.is_level? 'WARN'
    assert Gloo::App::Log.is_level? 'ERROR'

    refute Gloo::App::Log.is_level? 'OTHER'
    refute Gloo::App::Log.is_level? 'bugaboo'
    refute Gloo::App::Log.is_level? ''
    refute Gloo::App::Log.is_level? 1
    refute Gloo::App::Log.is_level? nil
  end

  #
  # Errors go to stderr (not stdout) so that a script driving gloo
  # can redirect them separately from the program's own output.
  #
  def test_error_is_written_to_stderr
    engine = Gloo::App::Engine.new( default_context )
    engine.start
    engine.log.quiet = false

    out, err = capture_io { engine.log.error 'something broke' }

    assert_equal '', out
    assert_match 'something broke', err
  end

  def log_for( quiet )
    engine = Gloo::App::Engine.new( default_context )
    return Gloo::App::Log.new( engine, quiet )
  end

  def test_errors_go_to_the_console_unless_quiet
    assert log_for( false ).errors_to_console?
    refute log_for( true ).errors_to_console?
  end

  def test_errors_can_be_kept_off_the_console
    log = log_for( false )
    log.console_errors = false
    refute log.errors_to_console?
    assert_output( '', '' ) do
      log.error 'not shown'
      log.warn 'not shown either'
    end
  end

  def test_errors_shown_on_the_console_by_default
    log = log_for( false )
    assert_output( /careful/, /boom/ ) do
      log.warn 'careful'
      log.error 'boom'
    end
  end

  def test_counts_errors_and_warnings
    log = log_for( true )
    assert_equal 0, log.error_count
    assert_equal 0, log.warning_count

    log.error 'one'
    log.error 'two'
    log.warn 'careful'
    log.backtrace 'part of the last error'
    assert_equal 2, log.error_count
    assert_equal 1, log.warning_count

    log.reset_counts
    assert_equal 0, log.error_count
    assert_equal 0, log.warning_count
  end

end
