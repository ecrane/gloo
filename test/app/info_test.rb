require 'test_helper'

class InfoTest < BaseTest

  def test_version_number
    refute_nil Gloo::App::Info::VERSION
  end

  def test_app_name
    refute_nil Gloo::App::Info::APP_NAME
  end

  def test_the_display_name
    t = Gloo::App::Info.display_title
    assert t
    assert t.start_with? 'Gloo'
    assert t.end_with? Gloo::App::Info::VERSION
  end

  def test_the_full_version
    t = Gloo::App::Info.full_version
    assert t
    assert t.start_with? 'Gloo'
  end

  def test_ruby_info
    t = Gloo::App::Info.ruby_info
    assert t
    assert t.include? RUBY_VERSION
  end

end
