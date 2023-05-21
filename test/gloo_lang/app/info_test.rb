require 'test_helper'
require 'gloo-lang'

class InfoTest < BaseTest

  def test_version_number
    refute_nil GlooLang::App::Info::VERSION
  end

  def test_app_name
    refute_nil GlooLang::App::Info::APP_NAME
  end

  def test_the_display_name
    t = GlooLang::App::Info.display_title
    assert t
    assert t.start_with? 'Gloo'
    assert t.end_with? GlooLang::App::Info::VERSION
  end

  def test_the_full_version
    t = GlooLang::App::Info.full_version
    assert t
    assert t.start_with? 'Gloo Engine'
    assert t.lines.count > 1
  end

end
