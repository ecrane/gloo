require 'test_helper'

class CreateTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'create', Gloo::Verbs::Create.keyword
  end

  def test_the_keyword_shortcut
    assert_equal '`', Gloo::Verbs::Create.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::Create.doc_data
    assert_equal Gloo::Verbs::Create.keyword, data[:name]
    assert_equal Gloo::Verbs::Create.keyword_shortcut, data[:shortcut]
  end

  def test_object_creation_default_type
    i = @engine.parser.parse_immediate '` x : 1'
    i.run
    assert_equal '1', @engine.heap.it.value
  end

  def test_object_creation_integer
    i = @engine.parser.parse_immediate '` x as integer : 1'
    i.run
    i = @engine.parser.parse_immediate 'show x'
    i.run
    assert_equal 1, @engine.heap.it.value
  end

  def test_object_creation
    @engine.parser.run 'create x as integer : 1'
    assert_equal 1, @engine.heap.root.child_count
    assert_equal 1, @engine.heap.root.children.first.value
  end

  def test_object_creation_without_name
    @engine.parser.run 'create'
    assert_equal 0, @engine.heap.root.child_count
    assert @engine.error?
    assert_equal Gloo::Verbs::Create::NO_NAME_ERR, @engine.heap.error.value
  end

  def test_object_creation_bad_path
    i = @engine.parser.parse_immediate '` x.y.z'
    i.run
    assert_equal 0, @engine.heap.root.child_count
  end

  def test_object_creation_with_alias
    assert_equal 0, @engine.heap.root.child_count

    i = @engine.parser.parse_immediate '` ln as alias : x'
    i.run
    assert_equal 1, @engine.heap.root.child_count

    i = @engine.parser.parse_immediate 'create ln* as string : "hello"'
    i.run
    s = @engine.heap.root.children.last
    assert s
    refute s.is_alias?
    assert_equal s.value, 'hello'
  end

  def test_create_with_missing_parent_is_an_error
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'create no.such.x as int : 1'
    assert @engine.error?
    assert_equal "Could not create 'no.such.x': Object 'no.such' was not found.",
      @engine.heap.error.value
    assert_equal false, @engine.heap.it.value
    assert_equal 0, @engine.heap.root.child_count
  end

  def test_create_with_unknown_type_creates_it_untyped
    @engine.parser.run 'create x as nosuchtype : 3'
    assert @engine.error?
    assert_equal Gloo::Core::Error::SYNTAX, @engine.heap.error.kind
    x = @engine.heap.root.find_child( 'x' )
    assert_equal 'untyped', x.type_display
    assert_equal '3', x.value
  end

  def test_create_it_is_an_error
    @engine.parser.run 'create c as can'
    @engine.parser.run "create c.x as string : 'ex'"
    @engine.parser.run "eval 'abc'"
    @engine.parser.run "create it as string"
    assert @engine.error?
    assert_includes @engine.heap.error.value, "it isn't an object and can't be created;"
    assert_equal 'abc', @engine.heap.it.value
  end

  def test_create_with_no_name_sets_it_false
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'create'
    assert @engine.error?
    assert_equal false, @engine.heap.it.value
  end

  def test_a_parenthesised_name_is_an_error_and_creates_nothing
    @engine.parser.run 'create n as int : 3'
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'create ( "list." + n ) as string : four'
    assert @engine.error?
    assert_includes @engine.heap.error.value, %q('( "list." + n )' isn't a name!)
    assert_includes @engine.heap.error.value, 'put the path into an alias'
    assert_equal false, @engine.heap.it.value
    assert_nil @engine.heap.root.find_child( '(' )
  end

  def test_extra_words_after_the_name_are_an_error
    @engine.parser.run 'create list as can'
    @engine.parser.run 'create list.x + 1 as string'
    assert @engine.error?
    assert_includes @engine.heap.error.value, "'list.x + 1' isn't a name!"
    assert_equal 0, @engine.heap.root.find_child( 'list' ).child_count
  end

  def test_quoted_and_parenthesised_names_are_errors
    [ 'create "x" as string', 'create list.(n) as string' ].each do |cmd|
      @engine.heap.error.clear
      @engine.parser.run cmd
      assert @engine.error?, cmd
    end
  end

  def test_valid_names_still_work
    @engine.parser.run 'create list as can'
    [ 'create list.1 as string : ok', 'create list.2 : ok', 'create list.3', 'create list.put as string' ].each do |cmd|
      @engine.heap.error.clear
      @engine.parser.run cmd
      refute @engine.error?, cmd
    end
    assert_equal 4, @engine.heap.root.find_child( 'list' ).child_count
  end

  def test_create_through_an_alias_computes_the_path
    @engine.parser.run 'create list as can'
    @engine.parser.run 'create n as int : 3'
    @engine.parser.run 'create slot as alias'
    @engine.parser.run "put 'list.' + n into slot*"
    @engine.parser.run 'create slot* as string'
    refute @engine.error?
    assert @engine.heap.root.find_child( 'list' ).find_child( '3' )
  end

  # ---------------------------------------------------------------------
  #    Here (^) and context (@) paths, like every other verb
  # ---------------------------------------------------------------------

  def test_create_with_a_here_path_in_a_script
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.box as can'
    @engine.parser.run 'create c.s as script : "create ^.box.made as int : 7"'
    @engine.parser.run 'run c.s'
    refute @engine.error?
    assert_equal 7, @engine.heap.root.find_child( 'c' ).find_child( 'box' ).find_child( 'made' ).value
  end

  def test_create_a_direct_child_with_a_here_path
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.s as script : "create ^.direct as int : 3"'
    @engine.parser.run 'run c.s'
    refute @engine.error?
    assert_equal 3, @engine.heap.root.find_child( 'c' ).find_child( 'direct' ).value
  end

  def test_create_with_a_two_level_here_path
    @engine.parser.run 'create a as can'
    @engine.parser.run 'create a.c as can'
    @engine.parser.run 'create a.c.s as script : "create ^^.up as int : 2"'
    @engine.parser.run 'run a.c.s'
    refute @engine.error?
    assert_equal 2, @engine.heap.root.find_child( 'a' ).find_child( 'up' ).value
  end

  def test_create_with_a_here_path_in_a_function
    @engine.parser.run 'create a as can'
    @engine.parser.run 'create a.fn as function'
    # the function already has an (empty) on_invoke; create would leave it be
    @engine.parser.run 'put "create ^.made as int : 4" into a.fn.on_invoke'
    @engine.parser.run 'invoke a.fn'
    made = @engine.heap.root.find_child( 'a' ).find_child( 'fn' ).find_child( 'made' )
    assert made, 'expected ^.made to be created under the function'
    assert_equal 4, made.value
  end

  def test_create_with_a_here_path_whose_parent_is_missing_names_it
    @engine.parser.run 'create c as can'
    @engine.parser.run 'create c.s as script : "create ^.nope.x as int : 1"'
    @engine.parser.run 'run c.s'
    assert @engine.error?
    assert_equal "Could not create '^.nope.x': #{Gloo::Core::NotFound.object( 'c.nope' )}",
                 @engine.heap.error.value
  end

  def test_create_with_a_context_path
    @engine.parser.run 'create c as can'
    @engine.parser.run 'context c'
    @engine.parser.run 'create @.x as int : 5'
    refute @engine.error?
    assert_equal 5, @engine.heap.root.find_child( 'c' ).find_child( 'x' ).value
  ensure
    @engine.parser.run 'context root'
  end

  def test_create_with_a_here_path_outside_a_script_is_an_error
    # There's nothing for ^ to be relative to.
    @engine.parser.run 'create ^.y as int : 1'
    assert @engine.error?
    assert_includes @engine.heap.error.value, Gloo::Core::NotFound.object( '^' )
  end

end
