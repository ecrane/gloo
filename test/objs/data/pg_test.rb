require 'test_helper'

class PgTest < BaseEngineTest

  def test_the_typename
    assert_equal 'postgres', Gloo::Objs::Pg.typename
  end

  def test_the_short_typename
    assert_equal 'pg', Gloo::Objs::Pg.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'postgres' )
    assert @dic.find_obj( 'pg' )
    assert @dic.find_obj( 'PG' )
  end

  def test_messages
    msgs = Gloo::Objs::Pg.messages
    assert msgs
    assert msgs.include?( 'verify' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Pg.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create o as pg'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 4, obj.child_count
    assert_equal 'host', obj.children.first.name
    assert_equal 'database', obj.children[ 1 ].name
    assert_equal 'username', obj.children[ 2 ].name
    assert_equal 'password', obj.children.last.name
  end

  def test_verify_mysql
    @engine.parser.run 'create o as pg'
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    @engine.parser.run "put 'localhost' into o.host"
    @engine.parser.run "tell o to verify"
    assert_equal false, @engine.heap.it.value
    assert @engine.error?
  end

end
