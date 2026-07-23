require 'test_helper'

class ShellContextTest < BaseTest

  def test_starts_not_done
    ctx = Gloo::Shell::Context.new
    refute ctx.done
  end

  def test_get_missing_property_is_empty_array
    ctx = Gloo::Shell::Context.new
    assert_equal [], ctx.get( :nope )
  end

  def test_set_and_get
    ctx = Gloo::Shell::Context.new
    ctx.set( :name, 'gloo' )
    assert_equal 'gloo', ctx.get( :name )
  end

  def test_set_and_get_with_string_key
    ctx = Gloo::Shell::Context.new
    ctx.set( :name, 'gloo' )
    assert_equal 'gloo', ctx.get( 'name' )
  end

  def test_has
    ctx = Gloo::Shell::Context.new
    refute ctx.has?( :name )
    ctx.set( :name, 'gloo' )
    assert ctx.has?( :name )
  end

  def test_keys
    ctx = Gloo::Shell::Context.new
    ctx.set( :a, 1 )
    ctx.set( :b, 2 )
    assert_equal [ :a, :b ], ctx.keys
  end

  def test_add_to_list
    ctx = Gloo::Shell::Context.new
    ctx.add_to_list( :items, 'one' )
    ctx.add_to_list( :items, 'two' )
    assert_equal %w[one two], ctx.get( :items )
  end

  def test_dynamic_getter_and_setter
    ctx = Gloo::Shell::Context.new
    ctx.verbs = %w[put show]
    assert_equal %w[put show], ctx.verbs
  end

  def test_dynamic_getter_for_unset_property
    ctx = Gloo::Shell::Context.new
    assert_equal [], ctx.anything
  end

  def test_respond_to_missing
    ctx = Gloo::Shell::Context.new
    ctx.set( :verbs, [] )
    assert ctx.respond_to?( :verbs )
  end

end
