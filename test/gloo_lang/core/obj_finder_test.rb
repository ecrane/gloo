require 'test_helper'

class ObjFinderTest < BaseEngineTest

  def test_by_name
    arr = GlooLang::Core::ObjFinder.by_name( @engine, 'x' )
    assert_equal [], arr

    i = @engine.parser.parse_immediate '` x'
    i.run
    arr = GlooLang::Core::ObjFinder.by_name( @engine, 'x' )
    assert_equal 1, arr.count
    assert_equal 'x', arr.first.name

    i = @engine.parser.parse_immediate '` x.y'
    i.run
    arr = GlooLang::Core::ObjFinder.by_name( @engine, 'y' )
    assert_equal 1, arr.count
    assert_equal 'y', arr.first.name
  end

end
