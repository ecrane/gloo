require 'test_helper'

class DirectiveNodeTest < BaseEngineTest

  def test_holds_raw_text
    n = Gloo::Persist::Source::DirectiveNode.new( 'load lib yaml' )
    assert_equal 'load lib yaml', n.raw
  end

end
