require 'test_helper'

class RunningAppTest < BaseTest

  def test_that_engine_does_not_initially_have_running_app
    o = Gloo::App::Engine.new( default_context )
    assert o
    refute o.running_app
    refute o.app_running?
  end
  
end
