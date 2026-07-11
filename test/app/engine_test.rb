require 'test_helper'

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

  def test_that_the_engine_has_args
    o = Gloo::App::Engine.new( default_context )
    assert o.args
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

end
