require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.warning = false
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

#
# Load and save a copy of every .gloo file under the given folders, and
# list the files that come back different. The originals are never
# written. For example:
#   rake "round_trip[~/gloo/app,~/dev/gloo_apps]"
#
desc 'Round-trip copies of .gloo files and list the ones that change'
task :round_trip do |_task, args|
  $LOAD_PATH.unshift File.expand_path( 'lib', __dir__ ), File.expand_path( 'test', __dir__ )
  require 'gloo'
  require 'round_trip_check'

  check = RoundTripCheck.new do
    engine = Gloo::App::Engine.new( Gloo::App::EngineContext.new( [ '--quiet' ] ) )
    engine.log.quiet = true
    engine.start
    engine
  end
  changed, count = check.check_folders( args.extras )
  changed.each { |path, diff| puts "#{path}\n  #{diff}" }
  puts "#{changed.size} of #{count} files changed."
end
