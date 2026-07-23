require 'test_helper'

class ShellRunnerTest < BaseEngineTest

  def test_default_prompt
    r = Gloo::Shell::Runner.new( @engine )
    assert_equal ' -> ', r.prompt
  end

  def test_custom_prompt_gets_a_trailing_space
    r = Gloo::Shell::Runner.new( @engine, prompt: 'help>' )
    assert_equal 'help> ', r.prompt
  end

  def test_handle_empty_command_calls_hook
    called = false
    r = Gloo::Shell::Runner.new( @engine, on_empty_command: -> { called = true } )
    r.handle_empty_command
    assert called
  end

  def test_handle_unknown_command_calls_hook_and_suppresses_default_message
    called = false
    r = Gloo::Shell::Runner.new( @engine, on_unknown_command: -> { called = true } )
    out, = capture_io { r.handle_unknown_command }
    assert called
    assert_equal '', out
  end

  def test_handle_unknown_command_default_message
    r = Gloo::Shell::Runner.new( @engine )
    out, = capture_io { r.handle_unknown_command }
    assert_equal "Unknown command\n", out
  end

  def test_before_and_after_action_hooks
    before_called = false
    after_called = false
    r = Gloo::Shell::Runner.new(
      @engine, before_action: -> { before_called = true },
      after_action: -> { after_called = true } )

    r.run_before_action
    r.run_after_action
    assert before_called
    assert after_called
  end

  def test_on_error_hook
    called = false
    r = Gloo::Shell::Runner.new( @engine, on_error: -> { called = true } )
    r.run_on_error
    assert called
  end

  def test_cmd_quit_sets_context_done
    r = Gloo::Shell::Runner.new( @engine )
    ctx = Gloo::Shell::Context.new
    refute ctx.done
    capture_io { r.cmd_quit( nil, ctx ) }
    assert ctx.done
  end

  def test_include_quit_adds_a_quit_command
    r = Gloo::Shell::Runner.new( @engine, include_quit: true )
    result = r.traverse( r.instance_variable_get( :@root ), [ 'quit' ] )
    refute_nil result[ :node ]
    assert_equal 'quit', result[ :node ].name
  end

  def test_no_quit_command_by_default
    r = Gloo::Shell::Runner.new( @engine )
    result = r.traverse( r.instance_variable_get( :@root ), [ 'quit' ] )
    assert_nil result[ :node ]
  end

  def test_add_command_node_simple
    r = Gloo::Shell::Runner.new( @engine )
    r.add_command_node( { name: 'verbs', description: 'List verbs', method: 'noop' } )

    result = r.traverse( r.instance_variable_get( :@root ), [ 'verbs' ] )
    assert_equal 'verbs', result[ :node ].name
    assert_equal 'List verbs', result[ :node ].description
  end

  def test_add_command_node_accumulates
    r = Gloo::Shell::Runner.new( @engine )
    r.add_command_node( { name: 'verbs', description: '', method: 'noop' } )
    r.add_command_node( { name: 'objects', description: '', method: 'noop' } )

    root = r.instance_variable_get( :@root )
    names = root.children( r.instance_variable_get( :@context ) ).map( &:name )
    assert_equal %w[verbs objects], names
  end

  def test_add_command_node_with_children
    r = Gloo::Shell::Runner.new( @engine )
    r.add_command_node( {
      name: 'verb',
      description: 'Verb commands',
      children: [
        { name: 'put', description: 'The put verb', method: 'noop' },
        { name: 'show', description: 'The show verb', method: 'noop' }
      ]
    } )

    result = r.traverse( r.instance_variable_get( :@root ), %w[verb put] )
    assert_equal 'put', result[ :node ].name
  end

  def test_add_command_node_dynamic
    r = Gloo::Shell::Runner.new( @engine )
    r.set_context( :verbs, %w[put show] )
    r.add_command_node( { name: 'verb', description: '', dynamic: true, source: :verbs } )

    root = r.instance_variable_get( :@root )
    ctx = r.instance_variable_get( :@context )
    result = r.traverse( root, [ 'verb' ] )
    names = result[ :node ].children( ctx ).map( &:name )
    assert_equal %w[put show], names
  end

  def test_execute_command_dispatches_to_method
    r = Gloo::Shell::Runner.new( @engine )
    def r.cmd_test_action( _obj, _context )
      @test_action_ran = true
    end

    node = Gloo::Shell::CommandNode.new( 'go', method: 'cmd_test_action' )
    r.execute_command( node, [ 'go' ] )
    assert r.instance_variable_get( :@test_action_ran )
  end

  def test_execute_once_runs_matching_command
    r = Gloo::Shell::Runner.new( @engine )
    r.add_command_node( { name: 'go', description: '', method: 'cmd_test_action' } )
    def r.cmd_test_action( _obj, _context )
      @test_action_ran = true
    end

    r.execute_once( [ 'go' ] )
    assert r.instance_variable_get( :@test_action_ran )
  end

  def test_execute_once_unknown_command_shows_message
    r = Gloo::Shell::Runner.new( @engine )
    out, = capture_io { r.execute_once( [ 'nope' ] ) }
    assert_equal "Unknown command\n", out
  end

  def test_traverse_empty_tokens_returns_root
    r = Gloo::Shell::Runner.new( @engine )
    root = r.instance_variable_get( :@root )
    result = r.traverse( root, [] )
    assert_same root, result[ :node ]
    assert_nil result[ :parent ]
  end

end
