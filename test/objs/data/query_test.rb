require 'test_helper'

class QueryTest < BaseEngineTest

  def test_the_typename
    assert_equal 'query', Gloo::Objs::Query.typename
  end

  def test_the_short_typename
    assert_equal 'sql', Gloo::Objs::Query.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'query' )
    assert @dic.find_obj( 'SQL' )
    assert @dic.find_obj( 'sql' )
  end

  def test_messages
    msgs = Gloo::Objs::Query.messages
    assert msgs
    assert msgs.include?( 'run' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Query.new @engine
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    i = @engine.parser.parse_immediate 'create o as sql'
    i.run
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 3, obj.child_count
    assert_equal 'database', obj.children.first.name
    assert_equal 'sql', obj.children[ 1 ].name
    assert_equal 'result', obj.children.last.name
  end

  # def test_sqlite_query
  #   @engine.parser.run 'create o as sqlite'
  #   @engine.parser.run "put 'test/test.db' into o.database"
  #   @engine.parser.run "create s as query"
  #   assert_equal 2, @engine.heap.root.child_count
  #   s = @engine.heap.root.children.last
  #   assert s
  #   assert_equal 3, s.child_count

  #   @engine.parser.run "put 'o' into s.database*"
  #   @engine.parser.run "put 'select * from key_values' into s.sql"

  #   r = s.children.last
  #   assert r
  #   assert_equal 0, r.child_count

  #   @engine.parser.run "tell s to run"
  #   assert r.child_count > 0
  # end

  # def test_single_row_check
  #   o = GlooLang::Objs::Query.new @engine
  #   data = [ 1, [ 1 ] ]
  #   assert o.single_row_result?( data )
  # end

  # def test_multiple_rows
  #   o = GlooLang::Objs::Query.new @engine
  #   data = [ [ 'one', 'two' ], [ '1', '2' ], [ 2, 3 ] ]
  #   refute o.single_row_result?( data )
  # end

  # def test_showing_multiple_rows
  #   o = GlooLang::Objs::Query.new @engine
  #   data = [ [ 'one', 'two' ], [ '1', '2' ], [ 2, 3 ] ]
  #   refute o.show_rows( data )
  # end

  # def test_showing_single_row
  #   o = GlooLang::Objs::Query.new @engine
  #   data = [ [ 'one', 'two' ], [ '1', '2' ] ]
  #   o.show_single_row( data )
  # end

end