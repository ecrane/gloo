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

end
