require 'test_helper'

class PutTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'put', GlooLang::Verbs::Put.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'p', GlooLang::Verbs::Put.keyword_shortcut
  end

  def test_put_into_str
    o = @engine.parser.parse_immediate 'create s as string'
    o.run
    assert_equal 1, @engine.heap.root.child_count
    s = @engine.heap.root.children.first
    assert_equal '', s.value

    o = @engine.parser.parse_immediate "put 'one' into s"
    o.run
    assert_equal 'one', s.value
  end

  def test_put_into_int
    o = @engine.parser.parse_immediate 'create i as int : 0'
    o.run
    assert_equal 1, @engine.heap.root.child_count
    i = @engine.heap.root.children.first
    assert_equal 0, i.value

    o = @engine.parser.parse_immediate 'put 147 into i'
    o.run
    assert_equal 147, i.value
  end

  def test_put_into_nonexistent_object
    o = @engine.parser.parse_immediate 'put 1 into x'
    o.run
    assert_equal 0, @engine.heap.root.child_count
  end

  def test_putting_without_src
    @engine.parser.run 'create b'
    @engine.parser.run 'put into b'
    assert @engine.error?
    assert_equal GlooLang::Verbs::Put::MISSING_EXPR_ERR, @engine.heap.error.value
  end

  def test_putting_without_into
    @engine.parser.run 'put x'
    assert @engine.error?
    assert_equal GlooLang::Verbs::Put::MISSING_EXPR_ERR, @engine.heap.error.value
  end

  def test_putting_without_dst
    @engine.parser.run 'put x into'
    assert @engine.error?
    assert_equal GlooLang::Verbs::Put::INTO_MISSING_ERR, @engine.heap.error.value
  end

  def test_dst_resolution_err
    @engine.parser.run 'put x into y'
    assert @engine.error?
    msg = GlooLang::Verbs::Put::TARGET_ERR
    assert @engine.heap.error.value.start_with? msg
  end

end
