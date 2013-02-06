# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'breaktime/version'

Gem::Specification.new do |gem|
  gem.name          = "breaktime"
  gem.version       = Breaktime::VERSION
  gem.authors       = ["Jon Cairns"]
  gem.email         = ["jon@joncairns.com"]
  gem.description   = %q{Enforce screen breaks at regular intervals.}
  gem.summary       = %q{Breaktime}
  gem.homepage      = "https://github.com/joonty/breaktime"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = ['breaktime']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib","lib/breaktime"]
end
