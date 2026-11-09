require 'test_helper'

class StringToIntegerTest < BaseEngineTest

  def test_conversion
    o = Gloo::Convert::StringToInteger.new
    assert o
    assert_equal 3, o.convert( '3' )
    assert_equal 0, o.convert( '0' )
    assert_equal 98765, o.convert( '98765' )
  end

  def test_blank_string_is_zero
    # Blank is no value: 0, the same as an integer with no value at all.
    o = Gloo::Convert::StringToInteger.new
    assert_equal 0, o.convert( '' )
  end

  def test_with_engine
    v = @engine.parser.parse_immediate 'create x as int'
    v.run
    x = @engine.heap.root.children.first
    assert_equal 0, x.value

    v = @engine.parser.parse_immediate 'put 11 into x'
    v.run
    assert_equal 11, x.value

    v = @engine.parser.parse_immediate "put '71' into x"
    v.run
    assert_equal 71, x.value
  end

  def test_valid
    o = Gloo::Convert::StringToInteger.new
    %w[42 -7 +3].each { |v| assert o.valid?( v, nil ), v }
    assert o.valid?( ' 42 ', nil )
    assert o.valid?( '', nil )
    %w[x 12abc 3.7].each { |v| refute o.valid?( v, nil ), v }
  end

  # Typed values use the same spellings as literals.
  def test_valid_matches_the_literal_spellings
    o = Gloo::Convert::StringToInteger.new
    %w[ 007 +5 -12 ].each { |s| assert o.valid?( s, nil ), s }
    assert o.valid?( ' 42 ', nil )
    %w[ 5. 1_000 2.5 ].each { |s| refute o.valid?( s, nil ), s }
  end

end
