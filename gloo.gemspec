
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
  # tty uses an older version of bundle
  # 
  # spec.add_development_dependency 'bundler', '~> 2.2.22'
  # spec.add_development_dependency 'bundler', '~> 2.3.17'
  spec.add_development_dependency 'bundler', '~> 1.17.3'
  spec.add_development_dependency 'minitest', '~> 5.1', '>= 5.14.2'
  # spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency "rake", '~> 13.0', '>= 13.0.1'

  spec.add_dependency "gloo-lang", '~> 1.1', ">= 1.1.0"

  spec.add_dependency "activesupport", '~> 6.1', ">= 6.1.5"
  # spec.add_dependency "activesupport", '~> 6.1', ">= 6.1.4.6"
  # spec.add_dependency "activesupport", '~> 5.2', ">= 5.2.4.3"
  # spec.add_dependency 'activesupport', '~> 5.2', '>= 5.2.1'
  spec.add_dependency 'chronic', '~> 0.10', '>= 0.10.2'
  spec.add_dependency 'colorize', '~> 0.8', '>= 0.8.1'
  spec.add_dependency 'tty', '~> 0.10', '>= 0.10.0'
  spec.add_dependency 'json', '~> 2.1', '>= 2.1.0'
  spec.add_dependency 'openssl', '~> 2.1', '>= 2.1.0'
  spec.add_dependency 'net-ssh', '~> 6.1', '>= 6.1.0'
  spec.add_dependency 'mysql2', '~> 0.5', '>= 0.5.3'
  spec.add_dependency 'sqlite3', '~> 1.4', '>= 1.4.2'
end
