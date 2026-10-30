require 'tmpdir'
require 'fileutils'

#
# Load a .gloo file and save it again with no changes; a lossless save
# gives back the same bytes. Shared by the round-trip unit test and the
# round_trip rake task.
#
# The file is loaded without running any scripts (no on_load, on_error
# or on_exception), so the check knows the file's own objects are
# untouched: some files change their own values when their scripts run.
# 'load lib' lines aren't run either.
# The file is loaded from, and saved to, a scratch copy -- never the
# original.
#
class RoundTripCheck

  #
  # Set up a check. make_engine is a block that returns a started engine
  # (each file gets a fresh one).
  #
  def initialize( &make_engine )
    @make_engine = make_engine
  end

  #
  # Round-trip one file. Returns nil when the saved copy is identical,
  # or the saved bytes when it isn't.
  #
  def check( path )
    Dir.mktmpdir do |dir|
      copy = File.join( dir, File.basename( path ) )
      FileUtils.cp( path, copy )
      original = File.binread( copy )

      engine = quiet_engine
      engine.persist_man.load( copy )
      engine.persist_man.save_all

      saved = File.binread( copy )
      return saved == original ? nil : saved
    end
  end

  #
  # Describe where saved differs from original: the first line that
  # differs, with its line number, or the length when one is a prefix
  # of the other.
  #
  def self.first_difference( original, saved )
    was = original.lines
    now = saved.lines
    i = was.zip( now ).index { |a, b| a != b } || [ was.size, now.size ].min
    return "line #{i + 1}:\n  was: #{was[ i ].inspect}\n  now: #{now[ i ].inspect}"
  end

  #
  # Round-trip every .gloo file under each folder (each folder is copied
  # first, so the originals are never written). Returns a list of
  # [ path, description of the first difference ] for files that
  # changed, and the number of files checked.
  #
  def check_folders( folders )
    changed = []
    count = 0
    folders.each do |folder|
      Dir.glob( File.join( File.expand_path( folder ), '**', '*.gloo' ) ).sort.each do |path|
        count += 1
        saved = check( path )
        changed << [ path, RoundTripCheck.first_difference( File.binread( path ), saved ) ] if saved
      rescue => e
        changed << [ path, "raised #{e.class}: #{e.message}" ]
      end
    end
    return changed, count
  end

  #
  # A fresh engine whose load runs no scripts, and loads no libraries
  # for 'load lib' lines (a library's types are registered for the
  # whole process; the check doesn't need them, since a declaration of
  # a type gloo doesn't know is still written back exactly).
  #
  def quiet_engine
    engine = @make_engine.call
    events = engine.event_manager
    %i[on_load on_error on_exception].each do |event|
      events.define_singleton_method( event ) { |*| }
    end
    parser = engine.parser
    directive = Gloo::Persist::FileLoader::LIB_DIRECTIVE
    parser.define_singleton_method( :run ) { |cmd| super( cmd ) unless cmd =~ directive }
    return engine
  end

end
