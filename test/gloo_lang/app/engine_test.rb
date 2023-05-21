require 'test_helper'

class EngineTest < BaseTest

  def test_engine_constrution
    o = GlooLang::App::Engine.new( default_context )
    assert o
  end

  def test_that_we_can_start_the_engine
    o = GlooLang::App::Engine.new( default_context )
    assert o
    o.start
    assert_equal GlooLang::App::Mode::EMBED, o.mode
  end

  def test_that_a_running_engine_has_a_mode
    o = GlooLang::App::Engine.new( default_context )
    assert o
    o.start
    assert o.mode
  end

  def test_that_the_engine_has_args
    o = GlooLang::App::Engine.new( default_context )
    assert o.args
  end

  def test_that_the_running_engine_has_a_parser
    o = GlooLang::App::Engine.new( default_context )
    o.start
    assert o.parser
  end

  def test_that_the_running_engine_has_an_object_heap
    o = GlooLang::App::Engine.new( default_context )
    o.start
    assert o.heap
  end

  def test_last_command_blank
    o = GlooLang::App::Engine.new( default_context )
    o.last_cmd = nil
    assert o.last_cmd_blank?
    o.last_cmd = ''
    assert o.last_cmd_blank?
    o.last_cmd = '  '
    assert o.last_cmd_blank?

    o.last_cmd = 'quit'
    refute o.last_cmd_blank?
  end

  def test_that_engine_has_object_factory
    o = GlooLang::App::Engine.new( default_context )
    o.start
    assert o.factory
  end

  def test_that_engine_has_persistence_manager
    o = GlooLang::App::Engine.new( default_context )
    o.start
    assert o.persist_man
  end

  def test_that_engine_has_an_execution_environment
    o = GlooLang::App::Engine.new( default_context )
    o.start
    assert o.exec_env
  end

  def test_that_engine_has_event_manager
    o = GlooLang::App::Engine.new( default_context )
    o.start
    assert o.event_manager
  end

  def test_that_engine_has_converter
    o = GlooLang::App::Engine.new( default_context )
    o.start
    assert o.converter
  end

  def test_last_cmd_blank
    o = GlooLang::App::Engine.new( default_context )
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
    o = GlooLang::App::Engine.new( default_context )
    refute o.running
    o.start
    assert o.running
    o.stop_running
    refute o.running
  end

  def test_serialization
    o = GlooLang::App::Engine.new( default_context )
    o.start
    str = 'test123'
    o.heap.it.set_to str
    o.prep_serialize
    data = o.serialize
    assert data
    e = GlooLang::App::Engine.deserialize data
    assert e
    assert_equal str, e.heap.it.value
  end
end
