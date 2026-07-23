require 'test_helper'

class BooleanTest < BaseEngineTest

  def test_the_typename
    assert_equal 'boolean', Gloo::Objs::Boolean.typename
  end

  def test_the_short_typename
    assert_equal 'bool', Gloo::Objs::Boolean.short_typename
  end

  def test_doc_data
    data = Gloo::Objs::Boolean.doc_data
    assert_equal Gloo::Objs::Boolean.typename, data[:name]
    assert_equal Gloo::Objs::Boolean.short_typename, data[:shortcut]
  end

  def test_is_boolean
    assert Gloo::Expr::LBoolean.boolean?( true )
    assert Gloo::Expr::LBoolean.boolean?( false )
    assert Gloo::Expr::LBoolean.boolean?( 'true' )
    assert Gloo::Expr::LBoolean.boolean?( 'false' )
    assert Gloo::Expr::LBoolean.boolean?( 'TRUE' )
    assert Gloo::Expr::LBoolean.boolean?( 'False' )
    refute Gloo::Expr::LBoolean.boolean?( 'a' )
    refute Gloo::Expr::LBoolean.boolean?( 1 )
  end

  def test_find_type
    assert @dic.find_obj( 'boolean' )
    assert @dic.find_obj( 'BOOLEAN' )
    assert @dic.find_obj( 'bool' )
    assert @dic.find_obj( 'BOOL' )
  end

  def test_coersing_value
    o = 'tRUe'
    assert_equal o.class.name, 'String'
    assert o.class.name == 'String'
    # I should be able to use this:
    assert o.is_a?( String )
    assert o.instance_of?( String )
    # but it doesn't work.  I don't know why.
  end

  def test_setting_the_value_to_true
    o = Gloo::Objs::Boolean.new @engine
    o.set_value( 3 )
    assert_equal true, o.value
    o.set_value( -1 )
    assert_equal true, o.value
    o.set_value( 1 )
    assert_equal true, o.value
    o.set_value( 'tRUe' )
    assert_equal true, o.value
    o.set_value( 'TRUE' )
    assert_equal true, o.value
    o.set_value( 't' )
    assert_equal true, o.value
  end

  def test_setting_the_value_to_false
    o = Gloo::Objs::Boolean.new @engine
    o.set_value( 0 )
    assert_equal false, o.value
    o.set_value( 'false' )
    assert_equal false, o.value
    o.set_value( 'FALSE' )
    assert_equal false, o.value
    o.set_value( 'f' )
    assert_equal false, o.value
  end

  def test_messages
    msgs = Gloo::Objs::Boolean.messages
    assert msgs
    assert msgs.include?( 'not' )
    assert msgs.include?( 'true' )
    assert msgs.include?( 'false' )
  end

  def test_that_it_not_is_a_container
    o = Gloo::Objs::Boolean.new @engine
    refute o.is_container?
  end

end
