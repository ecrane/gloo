
require 'test_helper'

class SvrTest < BaseEngineTest

  def test_the_typename
    assert_equal 'server', Gloo::Objs::Svr.typename
  end

  def test_the_short_typename
    assert_equal 'svr', Gloo::Objs::Svr.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'server' )
    assert @dic.find_obj( 'svr' )
  end

  def test_messages
    msgs = Gloo::Objs::Svr.messages
    assert msgs
    assert msgs.include?( 'start' )
    assert msgs.include?( 'stop' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Svr.new @engine
    assert o.add_children_on_create?
  end

end
