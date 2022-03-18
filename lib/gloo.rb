# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Start the Engine.
#

# Look for all required dependencies.
path = File.dirname( File.absolute_path( __FILE__ ) )
require File.join( path, 'dependencies.rb' )

module Gloo
  def self.run
    params = []
    ( params << '--cli' ) if ARGV.count.zero?
    GlooLang::App::Engine.new( params, Gloo::App::Platform, Gloo::App::Log ).start
  end
end
