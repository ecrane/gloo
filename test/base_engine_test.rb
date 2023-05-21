require 'test_helper'

class BaseEngineTest < BaseTest

  def setup
    @engine = Gloo::App::Engine.new( default_context )
    @engine.log.quiet = true
    @engine.start

    @dic = @engine.dictionary
  end

  def teardown
    @engine.stop_running
    @engine = nil
  end

end
