require 'test_helper'

class ColorizeTest < BaseEngineTest

  def test_the_typename
    assert_equal 'colorize', Gloo::Objs::Colorize.typename
  end

  def test_the_short_typename
    assert_equal 'color', Gloo::Objs::Colorize.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'colorize' )
    assert @dic.find_obj( 'color' )
  end

  def test_messages
    msgs = Gloo::Objs::Colorize.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Colorize.new( @engine )
    assert o.add_children_on_create?
  end

end
