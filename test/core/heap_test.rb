require 'test_helper'

class HeapTest < BaseEngineTest

  def test_heap_constrution
    o = Gloo::Core::Heap.new( @engine )
    assert o
    assert o.root
    assert 0, o.root.child_count

    assert o.context
    assert o.it
    assert o.error
  end

  def test_the_default_context
    o = @engine.heap.context
    assert o
    assert_equal Gloo::Core::Pn, o.class
    assert o.root?
  end

  def test_it_default
    assert @engine.heap.it
    refute @engine.heap.it.value
  end

  def test_error_default
    assert @engine.heap.error
    refute @engine.heap.error.value
  end

  def test_unload_object
    o = @engine.factory.create( { :name => 's', :type => 'string' } )
    assert_equal 1, @engine.heap.root.child_count
    @engine.heap.unload o
    assert_equal 0, @engine.heap.root.child_count
  end

  def test_error
    refute @engine.heap.error?
    @engine.heap.error.set_to( 'fail!' )
    assert @engine.heap.error?

    @engine.heap.error.clear
    refute @engine.heap.error?
  end

end
