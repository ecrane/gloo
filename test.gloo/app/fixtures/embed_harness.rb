#
# A Ruby program that creates a gloo engine in code, as an embedding
# app would, and prints how many files the engine was given.
#
# Run it with words on its own command line: the engine must not
# take them as files, so this should always print 0. The engine is
# never started, so nothing is loaded or saved even if it does.
#
# Requires this repo's lib/gloo by path, so it checks the source,
# not an installed gloo gem.
#
require_relative '../../../lib/gloo'

context = Gloo::App::EngineContext.new( [ '--quiet' ] )
print Gloo::App::Engine.new( context ).args.files.count
