require 'test_helper'

class SqliteTest < BaseEngineTest

  def test_the_typename
    assert_equal 'sqlite', Gloo::Objs::Sqlite.typename
  end

  def test_the_short_typename
    assert_equal 'sqlite', Gloo::Objs::Sqlite.short_typename
  end

  def test_find_type
    assert @dic.find_obj( 'sqlite' )
    assert @dic.find_obj( 'SQLITE' )
    assert @dic.find_obj( 'Sqlite' )
  end

  def test_messages
    msgs = Gloo::Objs::Sqlite.messages
    assert msgs
    assert msgs.include?( 'verify' )
    assert msgs.include?( 'unload' )
  end

  def test_adds_children_on_create
    o = Gloo::Objs::Sqlite.new( @engine )
    assert o.add_children_on_create?
  end

  def test_that_children_are_added_on_create
    @engine.parser.run 'create o as sqlite'
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    assert_equal 'o', obj.name
    assert_equal 1, obj.child_count
    assert_equal 'database', obj.children.first.name
  end

  def test_that_db_required_to_verify
    @engine.parser.run 'create o as sqlite'
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    @engine.parser.run "put '' into o.database"
    assert_equal '', obj.children.first.value
    @engine.parser.run "tell o to verify"
    assert_equal false, @engine.heap.it.value
    assert @engine.error?
    assert_equal Gloo::Objs::Sqlite::DB_REQUIRED_ERR, @engine.heap.error.value
  end

  def test_that_db_file_is_verified
    @engine.parser.run 'create o as sqlite'
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    @engine.parser.run "put 'test/test.xyz' into o.database"
    @engine.parser.run "tell o to verify"
    assert_equal false, @engine.heap.it.value
    assert @engine.error?
    assert_equal Gloo::Objs::Sqlite::DB_NOT_FOUND_ERR, @engine.heap.error.value
  end

  def test_opening_file_that_isnt_sqlite_db
    @engine.parser.run 'create o as sqlite'
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    @engine.parser.run "put 'test/test_helper.rb' into o.database"
    @engine.parser.run "tell o to verify"
    assert @engine.error?
    assert_equal 'file is not a database', @engine.heap.error.value
    assert_equal false, @engine.heap.it.value
  end

  def test_verify_for_test_db
    @engine.parser.run 'create o as sqlite'
    assert_equal 1, @engine.heap.root.child_count
    obj = @engine.heap.root.children.first
    assert obj
    @engine.parser.run "put 'test/test.db' into o.database"
    @engine.parser.run "tell o to verify"
    assert_equal true, @engine.heap.it.value
  end

end
