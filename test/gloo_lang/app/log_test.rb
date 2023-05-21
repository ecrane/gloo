require 'test_helper'

class LogTest < BaseEngineTest

  def test_creation
    e = GlooLang::App::Engine.new( default_context )
    assert e.log
  end

  def test_default_logger
    e = GlooLang::App::Engine.new( default_context )
    assert e.log.logger
    assert_equal Logger::DEBUG, e.log.logger.level
  end

  def test_quiet_logging
    assert @engine.log.quiet
  end

  # def test_noisy_logging_by_default
  #   GlooLang::App::Engine.new
  #   refute @engine.log.quiet
  # end

  def test_debug
    @engine.log.debug 'debug statement'
  end

  def test_info
    @engine.log.info 'info statement'
  end

  def test_warn
    @engine.log.warn 'warn statement'
  end

  def test_error
    @engine.log.error 'error statement'
  end

  def test_serialization
    l = @engine.log
    assert l.logger
    l.prep_serialize
    refute l.logger
    l.restore_after_deserialization
    assert l.logger
  end

end
