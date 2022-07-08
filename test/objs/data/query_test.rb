require 'test_helper'

class QueryTest < BaseEngineTest

  def test_sqlite_query
    @engine.parser.run 'create o as sqlite'
    @engine.parser.run "put 'test/test.db' into o.database"
    @engine.parser.run "create s as query"
    assert_equal 2, @engine.heap.root.child_count
    s = @engine.heap.root.children.last
    assert s
    assert_equal 3, s.child_count

    @engine.parser.run "put 'o' into s.database*"
    @engine.parser.run "put 'select * from key_values' into s.sql"

    r = s.children.last
    assert r
    assert_equal 0, r.child_count

    @engine.parser.run "tell s to run"
    assert r.child_count > 0
  end

end
