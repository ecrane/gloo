#
# The following can be used to run the application in CLI mode
# in development and use source rather than the gem.
#
# From the /lib/ directory:  ruby run.rb
#
require 'gloo/core/baseo'
require 'gloo/core/obj'

path = File.dirname( File.absolute_path( __FILE__ ) )
root = File.join( path, 'gloo', '**/*.rb' )
Dir.glob( root ) { |ruby_file| require ruby_file }

params = []
( params << '--cli' ) if ARGV.count.zero?
Gloo::App::Engine.new( params ).start
