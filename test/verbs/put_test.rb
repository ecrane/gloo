require 'test_helper'

class PutTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'put', Gloo::Verbs::Put.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'p', Gloo::Verbs::Put.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Put.doc_data
    assert_equal Gloo::Verbs::Put.keyword, data[:name]
    assert_equal Gloo::Verbs::Put.keyword_shortcut, data[:shortcut]
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

  def test_put_a_json_string_into_a_string
    @engine.parser.run 'create s as string : ORIGINAL'
    s = @engine.heap.root.children.first

    @engine.parser.run %q{put '{"x":1}' into s}
    refute @engine.error?
    assert_equal '{"x":1}', s.value
  end

  def test_put_a_string_with_escaped_double_quotes
    @engine.parser.run 'create s as string'
    s = @engine.heap.root.children.first

    @engine.parser.run 'put "say \\"hi\\"" into s'
    refute @engine.error?
    assert_equal 'say "hi"', s.value
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
    assert_equal Gloo::Verbs::Put::MISSING_EXPR_ERR, @engine.heap.error.value
  end

  def test_putting_without_into
    @engine.parser.run 'put x'
    assert @engine.error?
    assert_equal Gloo::Verbs::Put::MISSING_EXPR_ERR, @engine.heap.error.value
  end

  def test_putting_without_dst
    @engine.parser.run 'put x into'
    assert @engine.error?
    assert_equal Gloo::Verbs::Put::INTO_MISSING_ERR, @engine.heap.error.value
  end

  def test_dst_resolution_err
    @engine.parser.run 'put x into y'
    assert @engine.error?
    assert_equal Gloo::Core::NotFound.object( 'y' ), @engine.heap.error.value
  end

  def test_put_leaves_target_alone_when_value_is_missing
    @engine.parser.run 'create s as string : "keep me"'
    @engine.parser.run 'put no.such.obj into s'
    assert @engine.error?
    assert_equal 'keep me', @engine.heap.root.find_child( 's' ).value
  end

  def test_put_into_it_is_an_error
    @engine.parser.run 'create c as can'
    @engine.parser.run "create c.x as string : 'ex'"
    @engine.parser.run "eval 'abc'"
    @engine.parser.run "put 'x' into it"
    assert @engine.error?
    assert_includes @engine.heap.error.value, "it isn't an object and can't be put into;"
    assert_equal 'abc', @engine.heap.it.value
  end

  def test_put_into_missing_object_sets_it_false
    @engine.heap.it.set_to 'before'
    @engine.parser.run "put 'x' into no.such.obj"
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
  end

  def test_put_of_a_bad_value_sets_it_false_and_keeps_the_target
    @engine.parser.run "create s as string : 'keep'"
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'put no.such.value into s'
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
    assert_equal 'keep', @engine.heap.root.find_child( 's' ).value
  end

  def test_put_with_no_into_sets_it_false
    @engine.heap.it.set_to 'before'
    @engine.parser.run "put 'x'"
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
  end

  # ---------------------------------------------------------------------
  #    A computed object path: ( expr )
  # ---------------------------------------------------------------------

  def test_put_into_a_computed_path
    @engine.parser.run 'create counts as can'
    @engine.parser.run 'create counts.apples as int'
    @engine.parser.run "create k as string : 'apples'"
    @engine.parser.run "put 5 into ( 'counts.' k )"
    refute @engine.error?
    assert_equal 5, @engine.heap.root.find_child( 'counts' ).find_child( 'apples' ).value
  end

  def test_put_into_a_path_held_in_an_object
    @engine.parser.run 'create x as int'
    @engine.parser.run "create p as string : 'x'"
    @engine.parser.run 'put 7 into ( p )'
    assert_equal 7, @engine.heap.root.find_child( 'x' ).value
    assert_equal 'x', @engine.heap.root.find_child( 'p' ).value
  end

  def test_put_into_a_relative_computed_path
    @engine.parser.run 'create box as can'
    @engine.parser.run 'create box.slots as can'
    @engine.parser.run 'create box.slots.2 as int'
    @engine.parser.run 'create box.i as int : 2'
    @engine.parser.run 'create box.go as script'
    @engine.parser.run %q(put "put 9 into ( '^.slots.' ^.i )" into box.go)
    @engine.parser.run 'run box.go'
    refute @engine.error?
    assert_equal 9, @engine.heap.root.find_child( 'box' ).find_child( 'slots' ).find_child( '2' ).value
  end

  def test_put_into_a_missing_computed_path_names_the_worked_out_path
    @engine.parser.run "put 1 into ( 'no.' 'where' )"
    assert_includes @engine.heap.error.value, 'no.where'
    refute_includes @engine.heap.error.value, '('
    assert_equal false, @engine.heap.it.value
  end

  def test_put_into_a_blank_computed_path
    @engine.parser.run 'create b as string'
    @engine.parser.run 'put 1 into ( b )'
    assert_equal "Object path '( b )' is blank.", @engine.heap.error.value
    assert_equal false, @engine.heap.it.value
  end

end
