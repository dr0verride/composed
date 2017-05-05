# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'composed/version'

Gem::Specification.new do |spec|
  spec.name          = "composed"
  spec.version       = Composed::VERSION
  spec.authors       = ["Justin Scott"]
  spec.email         = ["jscott7561@gmail.com"]

  spec.summary       = "Tool for defining types or operations that are composed from other types."
  spec.description   = spec.description
  spec.homepage      = ""

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard", "~> 2.14.1"
  spec.add_development_dependency "guard-rspec", "~> 4.7.3"
  spec.add_development_dependency "byebug", "~> 9.0.6"
  spec.add_development_dependency "benchmark-ips", "~> 2.7.2"
end