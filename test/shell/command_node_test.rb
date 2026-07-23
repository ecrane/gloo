require 'test_helper'

class ShellCommandNodeTest < BaseTest

  def test_construction
    n = Gloo::Shell::CommandNode.new( 'put', description: 'Put a value' )
    assert_equal 'put', n.name
    assert_equal 'Put a value', n.description
    assert_nil n.method
    assert_nil n.obj
  end

  def test_leaf_node_has_no_children
    n = Gloo::Shell::CommandNode.new( 'put' )
    assert_equal [], n.children( nil )
  end

  def test_children_block_is_evaluated_with_context
    ctx = Gloo::Shell::Context.new
    ctx.set( :verbs, %w[put show] )

    n = Gloo::Shell::CommandNode.new( 'verb' ) do |context|
      context.get( :verbs ).map { |v| Gloo::Shell::CommandNode.new( v ) }
    end

    children = n.children( ctx )
    assert_equal 2, children.count
    assert_equal %w[put show], children.map( &:name )
  end

  def test_method_and_obj_are_stored
    obj = Object.new
    n = Gloo::Shell::CommandNode.new( 'quit', method: 'cmd_quit', obj: obj )
    assert_equal 'cmd_quit', n.method
    assert_same obj, n.obj
  end

end
