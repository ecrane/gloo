require 'test_helper'

class BaseEngineTest < BaseTest

  def setup
    @engine = Gloo::App::Engine.new( default_context )
    @engine.log.quiet = true
    @engine.start

    @dic = @engine.dictionary
  end

  #
  # Collect the warnings logged while the block runs.
  #
  def capture_warnings
    warnings = []
    @engine.log.define_singleton_method( :warn ) { |msg| warnings << msg }
    yield
    return warnings
  ensure
    @engine.log.singleton_class.send( :remove_method, :warn )
  end

  def teardown
    @engine.stop_running
    @engine = nil
  end

end
