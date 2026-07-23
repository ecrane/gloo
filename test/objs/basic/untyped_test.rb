require 'test_helper'

class UntypedTest < BaseEngineTest

  def test_the_typename
    assert_equal 'untyped', Gloo::Objs::Untyped.typename
  end

  def test_the_short_typename
    assert_equal 'any', Gloo::Objs::Untyped.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Untyped.doc_data
    assert_equal Gloo::Objs::Untyped.typename, data[:name]
    assert_equal Gloo::Objs::Untyped.short_typename, data[:shortcut]
  end

  def test_find_type
    assert @dic.find_obj( 'untyped' )
    assert @dic.find_obj( 'UNTYPED' )
    assert @dic.find_obj( 'any' )
    assert @dic.find_obj( 'ANY' )
  end

end
