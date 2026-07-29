
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gloo/app/info"

Gem::Specification.new do |spec|
  spec.name          = 'gloo'
  spec.version       = Gloo::App::Info::VERSION
  spec.authors       = ['Eric Crane']
  spec.email         = ['eric.crane@mac.com']

  spec.summary       = %q{Gloo scripting language.  A scripting language built on ruby.}
  spec.description   = %q{A scripting languge to keep it all together.}
  spec.homepage      = "http://github.com/ecrane/gloo"
  spec.license       = 'MIT'

  spec.metadata['documentation_uri'] = 'https://github.com/ecrane/gloo'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.executables << 'o'
  spec.executables << 'gloo'

  # 
  # Development Dependencies
  # 
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest', '~> 5.1', '>= 5.14.2'
  spec.add_development_dependency "rake", '~> 13.0', '>= 13.0.1'
  spec.add_development_dependency 'concurrent-ruby', '~> 1.3.7'

  # Used by many objects
  spec.add_dependency "activesupport", '~> 7.2.3.1'

  # Used by date and time tools
  spec.add_dependency 'chronic', '~> 0.10', '>= 0.10.2'

  # Used by json tools
  spec.add_dependency 'json', '~> 2.1', '>= 2.1.0'

  # Used by cipher string tool
  spec.add_dependency 'openssl'

  # Used by password generation
  spec.add_dependency 'bcrypt', '~> 3.1.20'

  # Used by gloo system
  spec.add_dependency 'os', '~> 1.1', '>= 1.1.4'

  # 
  # App UI libs
  # 
  spec.add_dependency 'colorize', '~> 1.1.0', '>= 1.1.0'
  spec.add_dependency 'inquirer'
  spec.add_dependency 'reline'  
  spec.add_dependency 'terminal-table'

end
