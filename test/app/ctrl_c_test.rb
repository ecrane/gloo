require 'test_helper'
require 'pty'

#
# Ctrl-C: it stops what's running and gives a clean prompt. In-process
# tests raise Interrupt the way Ruby does for a real Ctrl-C; the last
# test drives real gloo through a pseudo-terminal.
#
class CtrlCTest < BaseEngineTest

  def test_run_interruptible_says_whether_it_was_stopped
    assert @engine.run_interruptible { 1 }
    capture_warnings do
      refute @engine.run_interruptible { raise Interrupt }
    end
  end

  # Ctrl-C stopping a line: a warning that names the script and line,
  # and the run carries on.
  def test_stopping_a_script_names_where_it_stopped
    warnings = interrupt_script
    assert_equal [ 'Stopped by Ctrl-C: s, line 2.' ], warnings
    assert @engine.interrupted?
  end

  # It isn't an error: no error, not a failed run, and it keeps the
  # value of the last line that finished (show 2).
  def test_it_is_not_an_error
    interrupt_script
    refute @engine.error?
    refute @engine.run_failed?
    assert_equal 2, @engine.heap.it.value
  end

  def test_the_run_stacks_are_empty_after
    interrupt_script
    env = @engine.exec_env
    assert_equal [ 0, 0, 0, 0 ], [ env.verbs.size, env.actions.size, env.scripts.size, env.here.size ]
  end

  # Ctrl-C while a line is parsed (outside any verb) still names the
  # script it was in.
  def test_between_verbs_it_names_the_script
    o = Gloo::Objs::Script.new @engine
    o.set_value( 'show 1' )
    @engine.parser.define_singleton_method( :run ) { |*| raise Interrupt }
    warnings = capture_warnings do
      @engine.run_interruptible { Gloo::Exec::Script.new( @engine, o ).run }
    end
    assert_equal 1, warnings.size
    assert_match( /\AStopped by Ctrl-C: .*line 1\.\z/, warnings.first )
  end

  # At a prompt: with nothing typed, the hint; with text typed, nothing.
  def test_at_an_empty_prompt_it_shows_the_hint
    shown = capture_shown { @engine.interrupted_at_prompt( '' ) }
    assert_equal [ "Use 'quit' to stop running gloo." ], shown
    refute @engine.interrupted?
  end

  def test_at_a_prompt_with_text_it_shows_nothing
    shown = capture_shown { @engine.interrupted_at_prompt( 'show 1' ) }
    assert_empty shown
  end

  # Ctrl-C while quitting: stop quitting, and exit 130.
  def test_ctrl_c_while_quitting_exits_130
    @engine.event_manager.define_singleton_method( :on_quit ) { raise Interrupt }
    warnings = capture_warnings do
      ex = assert_raises( SystemExit ) { @engine.quit }
      assert_equal 130, ex.status
    end
    assert_equal [ 'Quit cut short by Ctrl-C.' ], warnings
  end

  # A real Ctrl-C at a terminal: script mode stops the run and leaves
  # gloo at its prompt; Ctrl-C at the empty prompt shows the hint; the
  # objects are there to look at; quit runs on_quit and exits 130.
  # Slow, so it runs only with GLOO_SLOW_TESTS set.
  def test_a_real_ctrl_c_at_a_terminal
    # About 5 seconds: run only when asked (see doc development, Tests).
    skip 'set GLOO_SLOW_TESTS=1 to run' unless ENV[ 'GLOO_SLOW_TESTS' ]

    file = File.expand_path( 'gloo/projects/app/ctrl_c.gloo', __dir__ + '/..' )
    out, status = drive_gloo( file, [ "\x03", "\x03", "show cc.x > 0\r", "quit\r" ] )
    # Where it stopped depends on timing: somewhere in cc.
    assert_includes out, 'Stopped by Ctrl-C: cc.'
    assert_includes out, "Use 'quit' to stop running gloo."
    assert_includes out, 'true'
    assert_includes out, 'on_quit ran'
    assert_equal 130, status
  end

  # How gloo's prompt ends.
  PROMPT_END = '> '.freeze

  private

  #
  # Wait until the block is true, or the seconds are up.
  #
  def wait_until( seconds )
    deadline = Time.now + seconds
    sleep 0.05 until yield || Time.now > deadline
  end

  #
  # Run script s, whose second line runs t; t is stopped by Ctrl-C.
  # Returns the warnings.
  #
  def interrupt_script
    @engine.parser.run 'create t as script : "show 1"'
    t = @engine.heap.root.find_child( 't' )
    t.define_singleton_method( :msg_run ) { raise Interrupt }
    @engine.parser.run 'create s as script'
    s = @engine.heap.root.find_child( 's' )
    s.set_array_value( [ 'show 2', 'run t', 'show 3' ] )
    return capture_warnings do
      @engine.run_interruptible { Gloo::Exec::Script.new( @engine, s ).run }
    end
  end

  #
  # Collect what's shown while the block runs.
  #
  def capture_shown
    shown = []
    @engine.log.define_singleton_method( :show ) { |msg, *| shown << msg }
    yield
    return shown
  ensure
    @engine.log.singleton_class.send( :remove_method, :show )
  end

  #
  # Run gloo on the file in a pseudo-terminal, typing each input in
  # turn ("\x03" is Ctrl-C). Returns what it printed, and its exit
  # status.
  #
  def drive_gloo( file, inputs )
    run_rb = File.expand_path( '../../lib/run.rb', __dir__ )
    out = +''
    status = nil
    PTY.spawn( 'ruby', run_rb, file ) do |r, w, pid|
      reader = Thread.new do
        loop { out << r.readpartial( 4096 ) }
      rescue EOFError, Errno::EIO
        nil
      end
      # Each input once gloo is ready for it: the first once the run is
      # going, the rest once a new prompt is up.
      sleep 2.5
      inputs.each do |i|
        prompts = out.scan( PROMPT_END ).size
        w.write( i )
        wait_until( 5 ) { out.scan( PROMPT_END ).size > prompts || i == "quit\r" }
        sleep 0.3
      end
      _, st = Process.wait2( pid )
      status = st.exitstatus
      reader.join( 1 )
    end
    return out.gsub( /\e\[[0-9;?]*[A-Za-z]/, '' ), status
  end

end
