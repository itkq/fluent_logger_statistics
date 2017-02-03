# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent_logger_statistics/version'

Gem::Specification.new do |spec|
  spec.name          = "fluent_logger_statistics"
  spec.version       = FluentLoggerStatistics::VERSION
  spec.authors       = ["Takuya Kosugiyama"]
  spec.email         = ["takuya-kosugiyama@cookpad.com"]

  spec.summary       = "Rack middleware for monitoring buffer of fluent-logger."
  spec.description   = "Rack middleware for monitoring buffer of fluent-logger."
  spec.homepage      = "https://github.com/itkq/fluent_logger_statistics"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "fluentd"
  spec.add_runtime_dependency "fluent-logger", "~> 0.5"
end
