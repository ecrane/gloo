require 'test_helper'

class ThemeTest < BaseEngineTest

  def test_defaults_to_dark
    theme = Gloo::App::Theme.new
    assert_equal 'dark', theme.name
  end

  def test_invalid_name_falls_back_to_dark
    theme = Gloo::App::Theme.new( 'purple' )
    assert_equal 'dark', theme.name
  end

  def test_light_theme_by_name
    theme = Gloo::App::Theme.new( 'light' )
    assert_equal 'light', theme.name
  end

  def test_for_engine_uses_engine_settings_theme
    theme = Gloo::App::Theme.for_engine( @engine )
    assert_equal @engine.settings.theme, theme.name
  end

  def test_for_engine_with_nil_engine_falls_back_to_dark
    theme = Gloo::App::Theme.for_engine( nil )
    assert_equal 'dark', theme.name
  end

  def test_apply_wraps_string_in_ansi_codes
    theme = Gloo::App::Theme.new( 'dark' )
    result = theme.apply( 'hello', :heading )
    assert_match "\e[", result
    assert_match 'hello', result
  end

  def test_apply_with_unknown_role_returns_plain_string
    theme = Gloo::App::Theme.new( 'dark' )
    assert_equal 'hello', theme.apply( 'hello', :not_a_real_role )
  end

  def test_role_methods_exist_for_every_role
    theme = Gloo::App::Theme.new( 'dark' )
    Gloo::App::Theme::ROLES.each do |role|
      result = theme.public_send( role, 'x' )
      assert_match 'x', result
    end
  end

  def test_emphasis_differs_between_dark_and_light
    dark = Gloo::App::Theme.new( 'dark' ).emphasis( 'x' )
    light = Gloo::App::Theme.new( 'light' ).emphasis( 'x' )
    refute_equal dark, light
  end

  def test_warn_uses_ansi_orange_on_light
    theme = Gloo::App::Theme.new( 'light' )
    assert_match Gloo::App::Theme::ORANGE, theme.warn( 'x' )
  end

  def test_subheading_uses_ansi_navy_on_light
    theme = Gloo::App::Theme.new( 'light' )
    assert_match Gloo::App::Theme::NAVY, theme.subheading( 'x' )
  end

  def test_accent_uses_ansi_dark_green_on_light
    theme = Gloo::App::Theme.new( 'light' )
    assert_match Gloo::App::Theme::DARK_GREEN, theme.accent( 'x' )
  end

  def test_warn_subheading_accent_stay_named_colors_on_dark
    theme = Gloo::App::Theme.new( 'dark' )
    refute_match Gloo::App::Theme::ORANGE, theme.warn( 'x' )
    refute_match Gloo::App::Theme::NAVY, theme.subheading( 'x' )
    refute_match Gloo::App::Theme::DARK_GREEN, theme.accent( 'x' )
  end

  def test_ansi_role_still_returns_plain_text_content
    theme = Gloo::App::Theme.new( 'light' )
    assert_match 'hello', theme.warn( 'hello' )
  end

  def test_accent_and_subheading_differ_between_dark_and_light
    dark = Gloo::App::Theme.new( 'dark' )
    light = Gloo::App::Theme.new( 'light' )
    refute_equal dark.accent( 'x' ), light.accent( 'x' )
    refute_equal dark.subheading( 'x' ), light.subheading( 'x' )
  end

  def test_subheading_stays_distinct_from_heading_on_light
    theme = Gloo::App::Theme.new( 'light' )
    refute_equal theme.heading( 'x' ), theme.subheading( 'x' )
  end

  def test_engine_exposes_theme_matching_settings
    assert @engine.theme
    assert_equal @engine.settings.theme, @engine.theme.name
  end

  def test_platform_theme_matches_engine_theme
    # Same object, not just equal - engine.theme reads through to
    # platform.theme rather than keeping an independent copy that
    # could drift if platform.theme were ever reassigned directly.
    assert_same @engine.theme, @engine.platform.theme
  end

end
