require 'test_helper'

class LogTest < Minitest::Test

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
end
