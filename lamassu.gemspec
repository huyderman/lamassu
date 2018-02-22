# frozen_string_literal: true

Gem::Specification.new do |spec|
  version_file = File.expand_path('VERSION', __dir__)
  version = File.read(version_file).lines.first.chomp

  spec.name    = 'lamassu'
  spec.version = version
  spec.authors = ['Jo-Herman Haugholt']
  spec.email   = ['jo-herman@sonans.no']

  spec.summary  = 'Autorization gem based on policy objects and dry-container'
  spec.homepage = 'https://github.com/Sonans/lamassu'
  spec.license  = 'MIT'

  spec.metadata['allowed_push_host'] = 'https://gem.fury.io'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dry-container', '~> 0.6.0'
  spec.add_runtime_dependency 'dry-inflector', '~> 0.1.1'
  spec.add_runtime_dependency 'dry-matcher', '~> 0.7.0'
  spec.add_runtime_dependency 'dry-monads', '~> 0.4.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'mutant', '~> 0.8.0'
  spec.add_development_dependency 'mutant-rspec', '~> 0.8.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'reek', '~> 4.7.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.52.0'
  spec.add_development_dependency 'simplecov', '~> 0.15.1'
end
