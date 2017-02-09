# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hyperlapse/version'

Gem::Specification.new do |spec|
  spec.name          = "hyperlapse"
  spec.version       = Hyperlapse::VERSION
  spec.authors       = ["Petr Schmied"]
  spec.email         = ["schmipe5@fit.cvut.cz"]

  spec.summary       = %q{Generates hyperlapse from Google My Maps paths.}
  spec.description   = %q{Generates hyperlapse from Google My Maps paths using Google Street View.}
  spec.homepage      = "https://gitlab.com/JBlackN/hyperlapse"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://mygemserver.com"
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

  spec.add_dependency "thor", "~> 0.19.4"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.post_install_message = 'Don\'t forget to set your API key. You can'\
                              ' use `hyperlapse config --api-key KEY`. See'\
                              ' README for more information.'
end
