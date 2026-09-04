require 'test_helper'

class BlankNodeTest < BaseEngineTest

  def test_defaults_to_empty_raw
    n = Gloo::Persist::Source::BlankNode.new
    assert_equal '', n.raw
  end

  def test_holds_given_raw_text
    n = Gloo::Persist::Source::BlankNode.new( '  ' )
    assert_equal '  ', n.raw
  end

end
