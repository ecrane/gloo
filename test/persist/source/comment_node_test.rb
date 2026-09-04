require 'test_helper'

class CommentNodeTest < BaseEngineTest

  def test_holds_raw_text
    n = Gloo::Persist::Source::CommentNode.new( '# hello' )
    assert_equal '# hello', n.raw
  end

end
