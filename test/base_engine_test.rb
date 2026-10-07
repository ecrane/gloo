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

  #
  # Pin the screen width, so tests that wrap text don't depend on the
  # width of the terminal running them.
  #
  def pin_screen_cols( cols = 80 )
    @engine.platform.define_singleton_method( :cols ) { cols }
  end

  def teardown
    @engine.stop_running
    @engine = nil
  end

end
