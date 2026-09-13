require 'test_helper'

class TriviaBufferTest < BaseEngineTest

  def buffer
    return Gloo::Persist::TriviaBuffer.new
  end

  def test_empty_buffer_flushes_nothing
    children = []
    buffer.flush_into( children )
    assert_equal [], children
  end

  def test_take_leading_doc_claims_a_matching_comment_run
    b = buffer
    b.push_comment( '# one', 1 )
    b.push_comment( '# two', 1 )

    children = []
    doc = b.take_leading_doc( 1, children )
    assert_equal "# one\n# two", doc
    assert_equal [], children
  end

  def test_take_leading_doc_flushes_a_mismatched_indent_run_instead
    b = buffer
    b.push_comment( '  # deeper', 2 )

    children = []
    doc = b.take_leading_doc( 1, children )
    assert_nil doc
    assert_equal 1, children.count
    assert_instance_of Gloo::Persist::Source::CommentNode, children.first
    assert_equal '  # deeper', children.first.raw
  end

  #
  # A blank line always breaks the leading_doc association -- only the
  # run *after* the last blank is eligible.
  #
  def test_a_blank_line_breaks_the_leading_doc_association
    b = buffer
    b.push_comment( '# detached', 1 )
    b.push_blank( '' )
    b.push_comment( '# attached', 1 )

    children = []
    doc = b.take_leading_doc( 1, children )
    assert_equal '# attached', doc

    # the detached comment and the blank both floated, in order
    assert_equal 2, children.count
    assert_instance_of Gloo::Persist::Source::CommentNode, children[ 0 ]
    assert_equal '# detached', children[ 0 ].raw
    assert_instance_of Gloo::Persist::Source::BlankNode, children[ 1 ]
  end

  def test_take_leading_doc_with_only_a_trailing_blank_claims_nothing
    b = buffer
    b.push_comment( '# one', 1 )
    b.push_blank( '' )

    children = []
    doc = b.take_leading_doc( 1, children )
    assert_nil doc
    assert_equal 2, children.count
  end

  def test_flush_into_preserves_order_of_mixed_trivia
    b = buffer
    b.push_comment( '# a', 0 )
    b.push_blank( '' )
    b.push_comment( '# b', 0 )

    children = []
    b.flush_into( children )
    assert_equal [ '# a', '', '# b' ], children.map { |n| n.respond_to?( :raw ) ? n.raw : nil }
  end

  def test_buffer_is_empty_after_take_leading_doc_either_way
    b = buffer
    b.push_comment( '# one', 1 )
    b.take_leading_doc( 1, [] )

    # a second call sees nothing left to claim or flush
    children = []
    assert_nil b.take_leading_doc( 1, children )
    assert_equal [], children
  end

end
