require 'test_helper'
require File.join( File.dirname( __dir__ ), 'lib', 'gloo.rb' )

class GlooEntryTest < BaseTest

  def test_no_argv_runs_the_cli
    assert_equal [ '--cli' ], Gloo.params_for( [] )
  end

  def test_argv_is_passed_through
    assert_equal [ '--quiet', 'one.gloo' ],
                 Gloo.params_for( [ '--quiet', 'one.gloo' ] )
  end

  def test_params_for_does_not_change_argv
    argv = [ 'one.gloo' ]
    Gloo.params_for( argv )
    assert_equal [ 'one.gloo' ], argv
  end

end
