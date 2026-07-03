require 'test_helper'

class ObjFinderTest < BaseEngineTest

  def test_by_name
    arr = Gloo::Core::ObjFinder.by_name( @engine, 'x' )
    assert_equal [], arr

    i = @engine.parser.parse_immediate '` x'
    i.run
    arr = Gloo::Core::ObjFinder.by_name( @engine, 'x' )
    assert_equal 1, arr.count
    assert_equal 'x', arr.first.name

    i = @engine.parser.parse_immediate '` x.y'
    i.run
    arr = Gloo::Core::ObjFinder.by_name( @engine, 'y' )
    assert_equal 1, arr.count
    assert_equal 'y', arr.first.name
  end

  def test_by_type
    arr = Gloo::Core::ObjFinder.by_type( @engine, 'string' )
    assert_equal [], arr

    @engine.parser.run '` s as string'
    arr = Gloo::Core::ObjFinder.by_type( @engine, 'string' )
    assert_equal 1, arr.count

    @engine.parser.run '` n as int'
    arr = Gloo::Core::ObjFinder.by_type( @engine, 'string' )
    assert_equal 1, arr.count
    arr = Gloo::Core::ObjFinder.by_type( @engine, 'integer' )
    assert_equal 1, arr.count

    @engine.parser.run '` s2 as string'
    arr = Gloo::Core::ObjFinder.by_type( @engine, 'string' )
    assert_equal 2, arr.count
  end

end
