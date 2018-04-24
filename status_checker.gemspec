# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "status_checker/version"

Gem::Specification.new do |spec|
  spec.authors = ["Peter Doherty"]
  spec.email = ["pdoherty@protonmail.com"]
  spec.license = "MIT"
  spec.name = "status-checker"
  spec.summary = <<~SUMMARY
    Checks status of a web page and calculates an average response time.
  SUMMARY
  spec.version = StatusChecker::VERSION

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "byebug", "~> 10.0.2"
  spec.add_development_dependency "m", "~> 1.5.1"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "mocha", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rest-client", "~> 2.0.2"
  spec.add_development_dependency "rubocop", "~> 0.48.1"
end
