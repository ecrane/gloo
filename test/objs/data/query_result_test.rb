require 'test_helper'

class QueryResultTest < BaseEngineTest

  def test_the_single_row_count
    h = []
    d = [ [ 1 ] ]
    o = Gloo::Objs::QueryResult.new( h, d )

    assert o
    assert o.single_row_result?

    d = []
    o = Gloo::Objs::QueryResult.new( h, d )
    refute o.single_row_result?

    d = [ [ 1 ], [ 2 ] ]
    o = Gloo::Objs::QueryResult.new( h, d )
  end

  def test_data_to_show
    o = Gloo::Objs::QueryResult.new( nil, nil )
    refute o.has_data_to_show?

    o = Gloo::Objs::QueryResult.new( [], [] )
    refute o.has_data_to_show?

    o = Gloo::Objs::QueryResult.new( nil, [] )
    refute o.has_data_to_show?

    o = Gloo::Objs::QueryResult.new( [], nil )
    refute o.has_data_to_show?

    o = Gloo::Objs::QueryResult.new( [ 1 ], [] )
    refute o.has_data_to_show?

    o = Gloo::Objs::QueryResult.new( nil, [ 1 ] )
    refute o.has_data_to_show?

    o = Gloo::Objs::QueryResult.new( nil, [] )
    refute o.has_data_to_show?

    d = [ [ 1 ], [ 2 ] ]
    o = Gloo::Objs::QueryResult.new( [ 1 ], d )
    assert o.has_data_to_show?
  end

end