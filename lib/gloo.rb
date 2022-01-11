# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Start the Engine.
#
require 'gloo/core/baseo'
require 'gloo/core/obj'

path = File.dirname( File.absolute_path( __FILE__ ) )
root = File.join( path, 'gloo', '**/*.rb' )
Dir.glob( root ).each do |ruby_file|
  require ruby_file
end

module Gloo
  def self.run
    params = []
    ( params << '--cli' ) if ARGV.count.zero?
    Gloo::App::Engine.new( params ).start
  end
end
