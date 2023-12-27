require 'test_helper'

class ArgsTest < BaseEngineTest

  def test_version_present
    o = Gloo::App::Args.new( @engine, [ '--version' ] )
    assert o.version?
    refute o.help?
  end

  def test_help_present
    o = Gloo::App::Args.new( @engine, [ '--help' ] )
    assert o.help?
    refute o.version?
  end

  def test_app_present
    o = Gloo::App::Args.new( @engine, [ '--app' ] )
    assert o.app?
    refute o.help?
  end

  def test_cli_present
    o = Gloo::App::Args.new( @engine, [ '--cli' ] )
    assert o.cli?
    refute o.help?
  end

  def test_embed_present
    o = Gloo::App::Args.new( @engine, [ '--embed' ] )
    assert o.embed?
    refute o.help?
  end

  def test_default_mode
    o = Gloo::App::Engine.new( default_context )
    assert o
    o.start
    assert_equal Gloo::App::Mode.default_mode, o.mode
  end

  def test_version_mode
    ctx = Gloo::App::EngineContext.new(
      [ '--version', '--quiet' ], nil, nil, default_user_root )

    o = Gloo::App::Engine.new( ctx )
    assert o
    o.start
    assert_equal Gloo::App::Mode::VERSION, o.mode
  end

  def test_help_mode
    ctx = Gloo::App::EngineContext.new(
      [ '--help', '--quiet' ], nil, nil, default_user_root )

    o = Gloo::App::Engine.new( ctx )
    assert o
    o.start
    assert_equal Gloo::App::Mode::HELP, o.mode
  end

  def test_cli_mode
    ctx = Gloo::App::EngineContext.new(
      [ '--cli', '--quiet' ], nil, nil, default_user_root )

    o = Gloo::App::Engine.new( ctx )
    assert o
    o.start
    assert_equal Gloo::App::Mode::CLI, o.mode
  end

  def test_embed_mode
    ctx = Gloo::App::EngineContext.new(
      [ '--embed', '--quiet' ], nil, nil, default_user_root )

    o = Gloo::App::Engine.new( ctx )
    assert o
    o.start
    assert_equal Gloo::App::Mode::EMBED, o.mode
  end

  def test_script_mode
    ctx = Gloo::App::EngineContext.new(
      [ 'test', '--quiet' ], nil, nil, default_user_root )

    o = Gloo::App::Engine.new( ctx )
    assert o
    o.start
    assert_equal Gloo::App::Mode::SCRIPT, o.mode
  end

  def test_quiet
    ctx = Gloo::App::EngineContext.new(
      [ '--quiet' ], nil, nil, default_user_root )
    o = Gloo::App::Engine.new( ctx )
    assert o
    assert o.args.quiet?

    ctx = Gloo::App::EngineContext.new( [], nil, nil, default_user_root )
    o = Gloo::App::Engine.new( ctx )
    assert o
    refute o.args.quiet?
  end

  def test_verify_app_mode_in_other_mode
    o = Gloo::App::Args.new( @engine, [ '--cli' ] )
    refute o.app?
    assert o.verify_app_mode
  end

  def test_verify_app_mode_no_path
    o = Gloo::App::Args.new( @engine, [ '--app' ] )
    assert o.app?
    refute o.verify_app_mode
  end

  def test_verify_app_mode_not_a_path
    o = Gloo::App::Args.new( @engine, [ '--app', 'abc' ] )
    assert o.app?
    refute o.verify_app_mode
  end

  def test_verify_app_mode_with_path
    o = Gloo::App::Args.new( @engine, [ '--app', '/Users' ] )
    assert o.app?
    assert o.verify_app_mode
  end

end
