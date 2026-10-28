# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2019 Eric Crane.  All rights reserved.
#
# Start the Engine.
#

# Look for all required dependencies.
path = File.dirname( File.absolute_path( __FILE__ ) )
require File.join( path, 'dependencies.rb' )

module Gloo

  #
  # Run gloo as the command, with the command line's arguments.
  # This is the only place that reads ARGV; an engine created
  # in code uses only the params it's given.
  #
  def self.run( argv = ARGV )
    platform = Gloo::App::Platform.new
    context = Gloo::App::EngineContext.new(
      params_for( argv ), platform, Gloo::App::Log, nil )
    Gloo::App::Engine.new( context ).start
  end

  #
  # Get the engine params for the given command line arguments.
  # With no arguments, gloo runs in CLI mode.
  #
  def self.params_for( argv )
    params = argv.dup
    ( params << '--cli' ) if params.empty?
    return params
  end

end
