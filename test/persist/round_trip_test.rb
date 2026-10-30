require 'test_helper'
require 'round_trip_check'

#
# Every .gloo file in the gloo test suite and the unit test fixtures
# loads and saves back byte-for-byte when nothing has changed. One test
# per file, so a failure names the file.
#
class RoundTripTest < BaseTest

  ROOT = File.expand_path( '../..', __dir__ )
  CORPUS = Dir.glob( File.join( ROOT, 'test.gloo', '**', '*.gloo' ) ) +
           Dir.glob( File.join( ROOT, 'test', 'gloo', 'projects', '**', '*.gloo' ) )

  CORPUS.sort.each do |path|
    rel = path.delete_prefix( "#{ROOT}/" )
    define_method( "test_round_trip #{rel}" ) do
      saved = round_trip_check.check( path )
      assert_nil saved, "#{rel} changed on save, " +
                        ( saved && RoundTripCheck.first_difference( File.binread( path ), saved ) ).to_s
    end
  end

  #
  # A check whose engines are quiet, started test engines.
  #
  def round_trip_check
    return RoundTripCheck.new do
      engine = Gloo::App::Engine.new( default_context )
      engine.log.quiet = true
      engine.start
      engine
    end
  end

end
