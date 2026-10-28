require 'test_helper'

class BaseTest < Minitest::Test

  #
  # Get the default context for an Engine in TEST.
  #
  def default_context
    return Gloo::App::EngineContext.new(
      [ '--quiet' ], nil, nil, default_user_root )
  end

  #
  # Get the default user root for testing.
  #
  def default_user_root
    path = File.dirname( File.dirname( File.absolute_path( __FILE__ ) ) )
    # path = File.dirname( File.dirname( path ) )
    path = File.join( path, 'test', 'gloo' )
    return path
  end

  #
  # Run a block with ARGV set to the given words, as if the host
  # process had been started with them, then put ARGV back.
  #
  def with_host_argv( words )
    saved = ARGV.dup
    ARGV.replace( words )
    yield
  ensure
    ARGV.replace( saved )
  end
  
end
