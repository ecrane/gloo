#
# The following can be used to run the application in CLI mode
# in development and use source rather than the gem.
#
# From the /lib/ directory:  ruby run.rb
#

# Look for all required dependencies.
path = File.dirname( File.absolute_path( __FILE__ ) )
require File.join( path, 'dependencies.rb' )

params = []
( params << '--cli' ) if ARGV.count.zero?
Gloo::App::Engine.new( params ).start
