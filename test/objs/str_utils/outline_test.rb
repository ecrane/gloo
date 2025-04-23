require 'test_helper'

class OutlineTest < BaseEngineTest

  def test_the_typename
    assert_equal 'outline', Gloo::Objs::Outline.typename
  end

  def test_the_short_typename
    assert_equal 'outline', Gloo::Objs::Outline.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'outline' )
    assert @dic.find_obj( 'OUTLINE' )
  end

  def test_messages
    msgs = Gloo::Objs::Outline.messages
    assert msgs
    assert msgs.include?( 'generate' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Outline.new @engine
    assert o.add_children_on_create?
  end

end
