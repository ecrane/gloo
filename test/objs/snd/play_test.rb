require 'test_helper'

class PlayTest < BaseEngineTest

  def test_the_typename
    assert_equal 'play', Gloo::Objs::Play.typename
  end

  def test_the_short_typename
    assert_equal 'play', Gloo::Objs::Play.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'Play' )
    assert @dic.find_obj( 'plAY' )
  end

  def test_messages
    msgs = Gloo::Objs::Play.messages
    assert msgs
    assert msgs.include?( 'run' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Play.new( @engine )
    refute o.add_children_on_create?
  end

end
