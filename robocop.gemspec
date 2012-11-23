# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "robocop"
  gem.version       = "0.1.1"
  gem.authors       = ["PJ Kelly"]
  gem.email         = ["me@pjkel.ly"]
  gem.description   = %q{Rack middleware that inserts the X-Robots-Tag into all responses.}
  gem.summary       = %q{Rack middleware that inserts the X-Robots-Tag into all responses.}
  gem.homepage      = "https://github.com/pjkelly/robocop"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'rack'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'fuubar'
  gem.add_development_dependency 'rb-fsevent'
  gem.add_development_dependency 'terminal-notifier-guard'
end
