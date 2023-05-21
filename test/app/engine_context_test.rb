require 'test_helper'

class EngineContextTest < BaseTest

  def test_creation
    o = Gloo::App::EngineContext.new
    assert o
    assert_equal [], o.params
    assert o.platform
    assert o.log
    refute o.user_root
  end

  def test_adding_param
    o = Gloo::App::EngineContext.new
    assert o
    assert_equal 0, o.params.count
    o.params << '--version'
    assert_equal 1, o.params.count
  end

  def test_context_platform
    platform = Gloo::App::Platform.new
    assert platform

    context = Gloo::App::EngineContext.new(
      [], platform, Gloo::App::Log, nil )
    assert context

    assert context.platform
    assert_same platform, context.platform
  end

  def test_context_log
    platform = Gloo::App::Platform.new
    log = Gloo::App::Log

    context = Gloo::App::EngineContext.new(
      [], platform, log, nil )
    assert context

    assert context.log
    assert_same log, context.log
  end

end
