require 'test_helper'

class SettingsTest < BaseEngineTest

  def test_creation
    s = GlooLang::App::Settings.new( @engine )
    assert s
    assert s.user_root
    assert s.log_path
    assert s.config_path
    assert s.project_path
  end

  def test_engine_settings
    assert @engine.settings
    assert @engine.settings.user_root
    assert @engine.settings.log_path
    assert @engine.settings.config_path
    assert @engine.settings.project_path
  end

end
