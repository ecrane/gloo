require 'test_helper'

class VerbTest < BaseEngineTest

  def test_verb_creation
    o = Gloo::Core::Verb.new( @engine, nil )
    assert o
    assert_equal( 0, o.params.count )
  end

  def test_verb_creation_with_params
    o = Gloo::Core::Verb.new( @engine, nil, [ 'one' ] )
    assert o
    assert_equal( 1, o.params.count )
    assert_equal( 'one', o.params.first )
  end

end
