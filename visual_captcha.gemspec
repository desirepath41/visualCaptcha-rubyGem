# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'visual_captcha/version'

Gem::Specification.new do |spec|
  spec.name          = "visual_captcha"
  spec.version       = VisualCaptcha::VERSION
  spec.authors       = ["emotionLoop"]
  spec.email         = "hello@emotionloop.com"
  spec.description   = "RubyGem package for visualCaptcha's backend service"
  spec.summary       = "visualCaptcha RubyGem Package"
  spec.homepage      = "http://emotionloop.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
