require 'test_helper'

class ExecEnvTest < BaseEngineTest

  def test_the_environment
    env = GlooLang::Exec::ExecEnv.new @engine
    assert env.verbs
    assert env.actions
    assert env.scripts
    assert env.here
  end

  def test_getting_engines_exec_env
    o = @engine.exec_env
    assert o
  end

  def test_verbs_stack
    o = @engine.exec_env.verbs
    assert o
    assert_equal 0, o.size
  end

  def test_actions_stack
    o = @engine.exec_env.actions
    assert o
    assert_equal 0, o.size
  end

  def test_scripts_stack
    o = @engine.exec_env.scripts
    assert o
    assert_equal 0, o.size
  end

  def test_here_obj_with_script
    refute @engine.exec_env.here_obj
    assert_equal 0, @engine.exec_env.scripts.size

    o = GlooLang::Objs::Script.new @engine
    o.set_value( 'show 2 + 3' )
    s = GlooLang::Exec::Script.new( @engine, o )
    @engine.exec_env.push_script s
    assert @engine.exec_env.here_obj
    assert_equal 1, @engine.exec_env.scripts.size

    @engine.exec_env.pop_script
    refute @engine.exec_env.here_obj
    assert_equal 0, @engine.exec_env.scripts.size
  end

  def test_here_obj_with_action
    refute @engine.exec_env.here_obj
    assert_equal 0, @engine.exec_env.actions.size

    o = GlooLang::Objs::Script.new @engine
    o.set_value( 'show 2 + 3' )
    s = GlooLang::Exec::Script.new( @engine, o )
    @engine.exec_env.push_action s
    refute @engine.exec_env.here_obj
    assert_equal 1, @engine.exec_env.actions.size

    @engine.exec_env.pop_action
    refute @engine.exec_env.here_obj
    assert_equal 0, @engine.exec_env.actions.size
  end


end
