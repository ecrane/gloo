require 'test_helper'

class IfTest < BaseEngineTest

  def test_the_keyword
    assert_equal 'if', Gloo::Verbs::If.keyword
  end

  def test_the_keyword_shortcut
    assert_equal 'if', Gloo::Verbs::If.keyword_shortcut
  end

  def test_doc_data
    data = Gloo::Verbs::If.doc_data
    assert_equal Gloo::Verbs::If.keyword, data[:name]
    assert_equal Gloo::Verbs::If.keyword_shortcut, data[:shortcut]
  end

  def test_evals_true
    v = @engine.parser.parse_immediate 'if true then show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_it_evals_true
    v = @engine.parser.parse_immediate 'show 2 + 5'
    v.run
    v = @engine.parser.parse_immediate 'if it then show 2 + 1'
    v.run
    assert_equal 3, @engine.heap.it.value
  end

  def test_it_evals_false
    v = @engine.parser.parse_immediate 'show 2 - 2'
    v.run
    v = @engine.parser.parse_immediate 'if it then show 2 + 1'
    v.run
    assert_equal 0, @engine.heap.it.value
  end

  def test_evals_false
    v = @engine.parser.parse_immediate 'show 2 + 3'
    v.run
    assert_equal 5, @engine.heap.it.value

    v = @engine.parser.parse_immediate 'if false then show 2 + 5'
    v.run
    assert_equal 5, @engine.heap.it.value
  end

  #
  # 'then' and 'do' are interchangeable separators.
  #
  def test_do_is_a_synonym_for_then
    v = @engine.parser.parse_immediate 'if true do show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
  end

  def test_else_runs_when_the_condition_is_false
    v = @engine.parser.parse_immediate 'if false then show 1 else show 2'
    v.run
    assert_equal 2, @engine.heap.it.value
  end

  def test_else_is_skipped_when_the_condition_is_true
    v = @engine.parser.parse_immediate 'if true then show 1 else show 2'
    v.run
    assert_equal 1, @engine.heap.it.value
  end

  def test_else_runs_with_the_do_synonym
    v = @engine.parser.parse_immediate 'if false do show 1 else show 2'
    v.run
    assert_equal 2, @engine.heap.it.value
  end

  #
  # The action's own separator keyword (here, unless's 'do') must not
  # be mistaken for if's -- 'then' is the first separator, so it wins.
  #
  def test_a_nested_unless_in_the_action_does_not_confuse_the_split
    v = @engine.parser.parse_immediate 'create x as boolean : false'
    v.run
    v = @engine.parser.parse_immediate 'if true then unless x do show 9'
    v.run
    assert_equal 9, @engine.heap.it.value
  end

  def test_obj_evals
    v = @engine.parser.parse_immediate 'create x as boolean : true'
    v.run
    v = @engine.parser.parse_immediate 'if x then show 2 + 5'
    v.run
    assert_equal 7, @engine.heap.it.value
    v = @engine.parser.parse_immediate 'put false into x'
    v.run
    v = @engine.parser.parse_immediate 'if x then show 5 - 2'
    v.run
    assert_equal false, @engine.heap.it.value
  end

  # A condition is like a loop's: if itself doesn't set it, so a failed
  # condition leaves it alone, and the branch doesn't run.
  def test_a_failed_condition_leaves_it_and_skips_the_branch
    @engine.parser.run 'create ran as bool : false'
    @engine.heap.it.set_to 'before'
    @engine.parser.run 'if no_such_obj then put true into ran'
    assert @engine.error?
    assert_equal 'before', @engine.heap.it.value
    assert_equal false, @engine.heap.root.find_child( 'ran' ).value
  end

  # Conditions use the [bool] rule: the text true counts as true.
  def test_the_text_true_is_true
    @engine.parser.run "create s as string : 'true'"
    @engine.parser.run "if s then put 'yes' into s"
    assert_equal 'yes', @engine.heap.root.find_child( 's' ).value
  end

  # A blank value is false, without a warning.
  def test_blank_is_false
    warnings = capture_warnings do
      @engine.parser.run 'create s as string'
      @engine.parser.run "if s then put 'then' into s else put 'else' into s"
    end
    assert_equal 'else', @engine.heap.root.find_child( 's' ).value
    assert_empty warnings
  end

  # Other text is false, with a warning.
  def test_other_text_is_false_with_a_warning
    warnings = capture_warnings do
      @engine.parser.run "create s as string : 'abc'"
      @engine.parser.run "if s then put 'then' into s else put 'else' into s"
    end
    assert_equal 'else', @engine.heap.root.find_child( 's' ).value
    assert_equal [ "'abc' is not true or false; using false." ], warnings
  end

  # A failed condition abandons the line: else doesn't run either.
  def test_a_failed_condition_skips_else_too
    @engine.parser.run 'create ran as bool : false'
    @engine.parser.run 'if no_such_obj then put true into ran else put true into ran'
    assert @engine.error?
    assert_equal false, @engine.heap.root.find_child( 'ran' ).value
  end

end
