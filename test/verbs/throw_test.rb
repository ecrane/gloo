require 'test_helper'

class ThrowTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'throw', Gloo::Verbs::Throw.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'throw', Gloo::Verbs::Throw.keyword_shortcut
  end

  def test_throw_fires_on_exception_with_the_given_message
    @engine.parser.run '` on_exception as script : "put true into ^.fired"'
    @engine.parser.run '` fired as bool : false'
    @engine.parser.run '` exception_data as can'
    @engine.parser.run '` exception_data.message as string'
    @engine.parser.run '` exception_data.backtrace as string'

    @engine.parser.run 'throw "custom message"'

    root = @engine.heap.root
    assert_equal true, root.find_child( 'fired' ).value
    assert_equal 'custom message', root.find_child( 'exception_data' ).find_child( 'message' ).value
  end

  def test_throw_with_no_message_uses_a_default
    @engine.parser.run '` on_exception as script : "put true into ^.fired"'
    @engine.parser.run '` fired as bool : false'
    @engine.parser.run '` exception_data as can'
    @engine.parser.run '` exception_data.message as string'
    @engine.parser.run '` exception_data.backtrace as string'

    @engine.parser.run 'throw'

    root = @engine.heap.root
    assert_equal true, root.find_child( 'fired' ).value
    refute_empty root.find_child( 'exception_data' ).find_child( 'message' ).value
  end

  def test_throw_does_not_fire_on_error
    @engine.parser.run '` on_error as script : "put true into ^.fired"'
    @engine.parser.run '` fired as bool : false'

    @engine.parser.run 'throw "boom"'

    refute_equal true, @engine.heap.root.find_child( 'fired' ).value
  end

  def test_execution_continues_after_throw
    @engine.parser.run 'throw "boom"'
    @engine.parser.run 'show 2 + 2'
    assert_equal 4, @engine.heap.it.value
  end

end
