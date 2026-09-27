require 'test_helper'

class IndentStackTest < Minitest::Test

  def setup
    @stack = Gloo::Persist::IndentStack.new( :root, :root_node )
  end

  def test_one_level_deeper_nests_under_the_line_above
    assert_nil @stack.place( 1, :a, :a_node )
    assert_equal :a, @stack.parent
    assert_equal :a_node, @stack.node
    assert_equal 1, @stack.tabs
  end

  def test_more_than_one_level_deeper_nests_and_is_reported
    assert_equal Gloo::Persist::IndentStack::OVER_INDENTED, @stack.place( 3, :a, :a_node )
    assert_equal :a, @stack.parent
  end

  def test_outdent_goes_back_to_the_level_it_lines_up_with
    @stack.place( 1, :a, :a_node )
    @stack.place( 3, :c, :c_node )
    assert_nil @stack.place( 1, :d, :d_node )
    assert_equal :a, @stack.parent
    assert_nil @stack.place( 0, :e, :e_node )
    assert_equal :root, @stack.parent
  end

  def test_outdent_between_levels_nests_under_the_closest
    @stack.place( 3, :a, :a_node )
    assert_equal Gloo::Persist::IndentStack::MISALIGNED, @stack.place( 1, :b, :b_node )
    assert_equal :a, @stack.parent
    assert_equal 1, @stack.tabs
  end

  def test_never_pops_the_root
    assert_nil @stack.place( 0, :a, :a_node )
    assert_equal :root, @stack.parent
  end

end
