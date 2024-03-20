
require 'test_helper'

class ElementTest < BaseEngineTest

  def test_the_typename
    assert_equal 'element', Gloo::Objs::Element.typename
  end

  def test_the_short_typename
    assert_equal 'e', Gloo::Objs::Element.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'element' )
    assert @dic.find_obj( 'e' )
  end

  def test_messages
    msgs = Gloo::Objs::Element.messages
    assert msgs
    assert msgs.include?( 'render' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Element.new @engine
    assert o.add_children_on_create?
  end

end
