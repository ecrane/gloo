#
# Script to build a list of dependencies
#

# require 'gloo_lang/core/baseo'
# require 'gloo_lang/core/obj'

path = File.dirname( File.absolute_path( __FILE__ ) )

files = []
#
# We want to start with these to avoid dependency errors later on.
#
files << File.join( path, 'gloo', 'core', 'baseo.rb' )
files << File.join( path, 'gloo', 'core', 'obj.rb' )

root = File.join( path, 'gloo_lang', '**/*.rb' )
Dir.glob( root ).each do |ruby_file|
  files << ruby_file unless files.include?( ruby_file )
end

root = File.join( path, 'gloo', '**/*.rb' )
Dir.glob( root ).each do |ruby_file|
  files << ruby_file unless files.include?( ruby_file )
end

#
# Now that we have the first with some key dependencies
# at the top, we'll require them.
#
files.each do |ruby_file|
  require ruby_file
end
