require "test_helper"

class QuitTest < Minitest::Test
  
  def test_quit_verb
    o = OutlineScript::App::Engine.new( [ "--quiet" ] )
    o.start
    assert o.running
    q = OutlineScript::Verbs::Quit.new
    q.run
    refute o.running
  end

  
end
