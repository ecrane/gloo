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

end
