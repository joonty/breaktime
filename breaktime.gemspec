# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'breaktime/version'

Gem::Specification.new do |gem|
  gem.name          = "breaktime"
  gem.version       = Breaktime::VERSION
  gem.authors       = ["Jon Cairns"]
  gem.email         = ["jon@joncairns.com"]
  gem.description   = %q{Enforce screen breaks at regular intervals, when you want them}
  gem.summary       = %q{Breaktime}
  gem.homepage      = "https://github.com/joonty/breaktime"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = ['breaktime']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.add_dependency 'green_shoes', '~> 1.1.373'
  gem.add_dependency 'trollop', '~> 2.0.0'
  gem.add_dependency 'rufus-scheduler', '~> 2.0.17'
  gem.add_dependency 'log4r', '~> 1.1.10'
  gem.add_dependency 'dante', '~> 0.1.5'
end
