require 'test_helper'

class BaseEngineTest < BaseTest

  def setup
    @engine = Gloo::App::Engine.new( default_context )
    @engine.log.quiet = true
    @engine.start

    @dic = @engine.dictionary
  end

  # The dictionary is shared by every test in the process: run the
  # block, then put back exactly what was registered before it, so
  # loading and unloading here can't change what another test sees.
  def keeping_the_dictionary_as_it_was
    saved = %i[@verbs @objs @keywords].to_h { |v| [ v, @dic.instance_variable_get( v ).dup ] }
    yield
  ensure
    saved.each { |v, value| @dic.instance_variable_set( v, value ) }
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
  # Collect the errors logged while the block runs.
  #
  def capture_errors
    errors = []
    @engine.log.define_singleton_method( :error ) { |msg, *| errors << msg }
    yield
    return errors
  ensure
    @engine.log.singleton_class.send( :remove_method, :error )
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
