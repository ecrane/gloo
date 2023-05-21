require 'test_helper'

class EngineContextTest < BaseTest

  def test_creation
    o = GlooLang::App::EngineContext.new
    assert o
    assert_equal [], o.params
    assert o.platform
    assert o.log
    refute o.user_root
  end

  def test_adding_param
    o = GlooLang::App::EngineContext.new
    assert o
    assert_equal 0, o.params.count
    o.params << '--version'
    assert_equal 1, o.params.count
  end

  def test_context_platform
    platform = GlooLang::App::Platform.new
    assert platform

    context = GlooLang::App::EngineContext.new(
      [], platform, GlooLang::App::Log, nil )
    assert context

    assert context.platform
    assert_same platform, context.platform
  end

  def test_context_log
    platform = GlooLang::App::Platform.new
    log = GlooLang::App::Log

    context = GlooLang::App::EngineContext.new(
      [], platform, log, nil )
    assert context

    assert context.log
    assert_same log, context.log
  end

end
