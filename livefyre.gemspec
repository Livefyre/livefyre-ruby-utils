# coding: utf-8
require File.expand_path('../lib/livefyre/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'livefyre'
  spec.version       = Livefyre::VERSION
  spec.authors       = ['Livefyre']
  spec.email         = ['tools@livefyre.com']
  spec.description   = %q{Livefyre Ruby utility classes}
  spec.summary       = %q{Livefyre Ruby utility classes}
  spec.post_install_message = <<-MESSAGE
  !   Note: this is a completely new version of the livefyre gem from Livefyre.
  !   Users that were using the previous livefyre gem (v.0.1.2) should now refer to livefyre-mashable.
  !   These two gems cannot be used in conjunction with one another as they share the same namespace.
  MESSAGE
  spec.homepage      = 'http://github.com/livefyre/livefyre-ruby-utils'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'rest-client', '~> 1.7', '>= 1.7.2'
  spec.add_runtime_dependency 'jwt', '~> 0.1', '>= 0.1.13'
  spec.add_runtime_dependency 'addressable', '~> 2.3', '>= 2.3.6'
  spec.add_development_dependency 'bundler', '~> 1.7', '>= 1.7.4'
  spec.add_development_dependency 'rspec', '~> 3.1', '>= 3.1'
  spec.add_development_dependency 'coveralls', '~> 0.7.1'
  spec.add_development_dependency 'simplecov', '~> 0.9.1'
  
end
