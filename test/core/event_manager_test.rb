require 'test_helper'

class EventManagerTest < BaseEngineTest

  def test_on_load
    cmd = '` on_load as script : "show 2 + 2"'
    i = @engine.parser.parse_immediate cmd
    i.run

    refute_equal 4, @engine.heap.it.value
    @engine.event_manager.on_load nil, true
    assert_equal 4, @engine.heap.it.value
  end

  def test_on_unload
    cmd = '` can as can'
    i = @engine.parser.parse_immediate cmd
    i.run

    cmd = '` can.on_unload as script : "show 2 + 3"'
    i = @engine.parser.parse_immediate cmd
    i.run
    refute_equal 5, @engine.heap.it.value

    i = @engine.parser.parse_immediate 'tell can to unload'
    i.run
    assert_equal 5, @engine.heap.it.value
  end

  def test_on_reload
    @engine.parser.run '` can as can'
    @engine.parser.run '` can.on_reload as script : "show 7 + 1"'
    refute_equal 8, @engine.heap.it.value

    @engine.event_manager.on_reload @engine.heap.root.find_child( 'can' )
    assert_equal 8, @engine.heap.it.value
  end

  def test_on_save
    @engine.parser.run '` can as can'
    @engine.parser.run '` can.on_save as script : "show 3 + 3"'
    refute_equal 6, @engine.heap.it.value

    @engine.event_manager.on_save @engine.heap.root.find_child( 'can' )
    assert_equal 6, @engine.heap.it.value
  end

  def test_on_quit
    @engine.parser.run '` on_quit as script : "show 9 + 1"'
    refute_equal 10, @engine.heap.it.value

    @engine.event_manager.on_quit
    assert_equal 10, @engine.heap.it.value
  end

  def test_on_error
    @engine.parser.run '` on_error as script : "put true into ^.fired"'
    @engine.parser.run '` fired as bool : false'
    @engine.parser.run '` error_data as can'
    @engine.parser.run '` error_data.message as string'
    @engine.parser.run '` error_data.backtrace as string'

    @engine.event_manager.on_error( 'boom', 'trace' )

    root = @engine.heap.root
    assert_equal true, root.find_child( 'fired' ).value
    assert_equal 'boom', root.find_child( 'error_data' ).find_child( 'message' ).value
    assert_equal 'trace', root.find_child( 'error_data' ).find_child( 'backtrace' ).value
  end

  def test_on_error_without_error_data_does_not_raise
    @engine.parser.run '` on_error as script : "show 1 + 1"'
    @engine.event_manager.on_error( 'boom', 'trace' )
    assert_equal 2, @engine.heap.it.value
  end

  def test_on_exception
    @engine.parser.run '` on_exception as script : "put true into ^.fired"'
    @engine.parser.run '` fired as bool : false'
    @engine.parser.run '` exception_data as can'
    @engine.parser.run '` exception_data.message as string'
    @engine.parser.run '` exception_data.backtrace as string'

    @engine.event_manager.on_exception( 'boom', 'trace' )

    root = @engine.heap.root
    assert_equal true, root.find_child( 'fired' ).value
    assert_equal 'boom', root.find_child( 'exception_data' ).find_child( 'message' ).value
    assert_equal 'trace', root.find_child( 'exception_data' ).find_child( 'backtrace' ).value
  end

  def test_on_error_and_on_exception_are_independent
    @engine.parser.run '` on_error as script : "put true into ^.error_fired"'
    @engine.parser.run '` error_fired as bool : false'
    @engine.parser.run '` on_exception as script : "put true into ^.exception_fired"'
    @engine.parser.run '` exception_fired as bool : false'

    @engine.event_manager.on_error( 'boom', 'trace' )

    root = @engine.heap.root
    assert_equal true, root.find_child( 'error_fired' ).value
    assert_equal false, root.find_child( 'exception_fired' ).value
  end

end
