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

  # ---------------------------------------------------------------------
  #    Verbs that take no object
  # ---------------------------------------------------------------------

  def test_extra_words_empty_for_a_bare_verb
    v = @engine.parser.parse_immediate 'cls'
    assert_equal '', v.extra_words
  end

  def test_extra_words_include_words_and_params
    v = @engine.parser.parse_immediate 'cls now ( 3 )'
    assert_equal 'now 3', v.extra_words
  end

  def test_extra_words_with_no_tokens
    v = Gloo::Verbs::Help.new( @engine, nil )
    assert_equal '', v.extra_words
  end

end
