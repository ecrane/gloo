require 'test_helper'

class StringToDecimalTest < BaseEngineTest

  def test_conversion
    o = Gloo::Convert::StringToDecimal.new
    assert o
    assert_equal 3.1, o.convert( '3.1' )
    assert_equal 0.0, o.convert( '0.0' )
    assert_equal 987.65, o.convert( '987.65' )
  end

  def test_with_engine
    @engine.parser.run 'create x as decimal'
    x = @engine.heap.root.children.first
    assert_equal 0.0, x.value

    @engine.parser.run 'put 1.1 into x'
    assert_equal 1.1, x.value

    @engine.parser.run "put '7.1' into x"
    assert_equal 7.1, x.value
  end

  def test_valid
    o = Gloo::Convert::StringToDecimal.new
    %w[1.5 -2 1e3].each { |v| assert o.valid?( v, nil ), v }
    assert o.valid?( '', nil )
    %w[x 1,5 1.5.5].each { |v| refute o.valid?( v, nil ), v }
  end

  # Typed values use the same spellings as literals.
  def test_valid_matches_the_literal_spellings
    o = Gloo::Convert::StringToDecimal.new
    %w[ 2.50 .5 1.0e3 7 007 +5 ].each { |s| assert o.valid?( s, nil ), s }
    %w[ 5. 1_000 0x1A abc ].each { |s| refute o.valid?( s, nil ), s }
  end

  # Hex was taken as valid, then read as 0.0 without a warning.
  def test_hex_warns
    warnings = capture_warnings do
      @engine.parser.run 'create x as decimal'
      @engine.parser.run "put '0x1A' into x"
    end
    assert_equal 1, warnings.size
  end

  def test_trailing_zeros_at_load
    @engine.parser.run 'create d as decimal : 2.50'
    assert_equal 2.5, @engine.heap.root.find_child( 'd' ).value
  end

end
