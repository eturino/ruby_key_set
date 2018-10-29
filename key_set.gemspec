# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'key_set/version'

Gem::Specification.new do |spec|
  spec.name          = 'key_set'
  spec.version       = KeySet::VERSION
  spec.authors       = ['Eduardo Turiño']
  spec.email         = ['eturino@eturino.com']

  spec.summary       = <<~TXT
    KeySet with 4 classes to represent concepts of All, None, Some, and AllExceptSome, the last 2 with a sorted uniq list of keys
  TXT
  spec.homepage      = 'https://github.com/eturino/ruby_key_set'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 4'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
