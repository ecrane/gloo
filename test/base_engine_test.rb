require 'test_helper'

class BaseEngineTest < BaseTest

  def setup
    @engine = GlooLang::App::Engine.new( [ '--quiet' ] )
    @engine.log.quiet = true
    @engine.start

    @dic = @engine.dictionary
  end

  def teardown
    @engine.stop_running
    @engine = nil
  end

end
