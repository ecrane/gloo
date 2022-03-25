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

    platform = Gloo::App::Platform.new
    context = GlooLang::App::EngineContext.new(
      params, platform, Gloo::App::Log, nil )
    GlooLang::App::Engine.new( context ).start
  end
end
