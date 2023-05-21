require 'test_helper'

class ArgsTest < BaseEngineTest

  def test_version_present
    o = GlooLang::App::Args.new( @engine, [ '--version' ] )
    assert o.version?
    refute o.help?
  end

  def test_help_present
    o = GlooLang::App::Args.new( @engine, [ '--help' ] )
    assert o.help?
    refute o.version?
  end

  def test_cli_present
    o = GlooLang::App::Args.new( @engine, [ '--cli' ] )
    assert o.cli?
    refute o.help?
  end

  def test_embed_present
    o = GlooLang::App::Args.new( @engine, [ '--embed' ] )
    assert o.embed?
    refute o.help?
  end

  def test_default_mode
    o = GlooLang::App::Engine.new( default_context )
    assert o
    o.start
    assert_equal GlooLang::App::Mode.default_mode, o.mode
  end

  def test_version_mode
    ctx = GlooLang::App::EngineContext.new(
      [ '--version', '--quiet' ], nil, nil, default_user_root )

    o = GlooLang::App::Engine.new( ctx )
    assert o
    o.start
    assert_equal GlooLang::App::Mode::VERSION, o.mode
  end

  def test_help_mode
    ctx = GlooLang::App::EngineContext.new(
      [ '--help', '--quiet' ], nil, nil, default_user_root )

    o = GlooLang::App::Engine.new( ctx )
    assert o
    o.start
    assert_equal GlooLang::App::Mode::HELP, o.mode
  end

  def test_cli_mode
    ctx = GlooLang::App::EngineContext.new(
      [ '--cli', '--quiet' ], nil, nil, default_user_root )

    o = GlooLang::App::Engine.new( ctx )
    assert o
    o.start
    assert_equal GlooLang::App::Mode::CLI, o.mode
  end

  def test_embed_mode
    ctx = GlooLang::App::EngineContext.new(
      [ '--embed', '--quiet' ], nil, nil, default_user_root )

    o = GlooLang::App::Engine.new( ctx )
    assert o
    o.start
    assert_equal GlooLang::App::Mode::EMBED, o.mode
  end

  def test_script_mode
    ctx = GlooLang::App::EngineContext.new(
      [ 'test', '--quiet' ], nil, nil, default_user_root )

    o = GlooLang::App::Engine.new( ctx )
    assert o
    o.start
    assert_equal GlooLang::App::Mode::SCRIPT, o.mode
  end

  def test_quiet
    ctx = GlooLang::App::EngineContext.new(
      [ '--quiet' ], nil, nil, default_user_root )
    o = GlooLang::App::Engine.new( ctx )
    assert o
    assert o.args.quiet?

    ctx = GlooLang::App::EngineContext.new( [], nil, nil, default_user_root )
    o = GlooLang::App::Engine.new( ctx )
    assert o
    refute o.args.quiet?
  end

end
