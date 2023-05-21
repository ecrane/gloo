require 'test_helper'

class StatsTest < BaseEngineTest

  def test_that_stats_are_not_valid_without_dir
    o = GlooLang::Utils::Stats.new( @engine, "", '' )
    assert o
    refute o.valid?
  end

  def test_that_stats_are_not_valid_without_root_dir
    o = GlooLang::Utils::Stats.new( @engine, "bla bla", '' )
    assert o
    refute o.valid?
  end

  def test_that_stats_are_valid_for_home_dir
    o = GlooLang::Utils::Stats.new(
      @engine, @engine.settings.project_path, '' )
    assert o
    assert o.valid?
  end

end
