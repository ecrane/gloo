$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'minitest/autorun'

# Look up a level from test, then in the lib folder
# for the dependency loading helper.
path = File.dirname( File.dirname( File.absolute_path( __FILE__ ) ) )
require File.join( path, 'lib', 'dependencies.rb' )
