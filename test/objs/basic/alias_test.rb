require 'test_helper'

class AliasTest < BaseEngineTest

  def test_the_typename
    assert_equal 'alias', Gloo::Objs::Alias.typename
  end

  def test_the_short_typename
    assert_equal 'ln', Gloo::Objs::Alias.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'alias' )
    assert @dic.find_obj( 'ALIAS' )
    assert @dic.find_obj( 'ln' )
    assert @dic.find_obj( 'LN' )
  end

  def test_alias_resolve_message
    o = @engine.parser.parse_immediate 'create s as string : up'
    o.run
    o = @engine.parser.parse_immediate 'create ln as alias : s'
    o.run
    o = @engine.parser.parse_immediate 'tell ln* to resolve'
    o.run
    assert_equal true, @engine.heap.it.value

    o = @engine.parser.parse_immediate "put 'x' into ln*"
    o.run
    o = @engine.parser.parse_immediate 'tell ln* to resolve'
    o.run
    assert_equal false, @engine.heap.it.value
  end

  def test_show_value_of_alias
    o = @engine.parser.parse_immediate 'create s as string : up'
    o.run
    str = @engine.heap.root.children.first
    assert_equal 'up', str.value
    o = @engine.parser.parse_immediate 'create ln as alias : s'
    o.run

    @engine.log.quiet = true
    o = @engine.parser.parse_immediate "show ln*"
    o.run
    assert_equal 's', @engine.heap.it.value
  end

  def test_show_value_in_referenced_obj
    o = @engine.parser.parse_immediate 'create s as string : up'
    o.run
    str = @engine.heap.root.children.first
    assert_equal 'up', str.value
    o = @engine.parser.parse_immediate 'create ln as alias : s'
    o.run

    @engine.log.quiet = true
    o = @engine.parser.parse_immediate "show ln"
    o.run
    assert_equal 'up', @engine.heap.it.value
  end

  def test_putting_value_in_referenced_obj
    o = @engine.parser.parse_immediate 'create s as string : up'
    o.run
    str = @engine.heap.root.children.first
    assert_equal 'up', str.value
    o = @engine.parser.parse_immediate 'create ln as alias : s'
    o.run

    o = @engine.parser.parse_immediate "put 'down' into ln"
    o.run
    assert_equal 'down', str.value
  end

  def test_up_msg_ln_to_string
    o = @engine.parser.parse_immediate 'create s as string : up'
    o.run
    str = @engine.heap.root.children.first
    assert_equal 'up', str.value
    o = @engine.parser.parse_immediate 'create ln as alias : s'
    o.run

    o = @engine.parser.parse_immediate 'tell ln to up'
    o.run
    assert_equal 'UP', str.value
  end

end
