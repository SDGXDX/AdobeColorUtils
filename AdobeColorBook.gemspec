# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'AdobeColorUtils/version'

Gem::Specification.new do |spec|
  spec.name          = "AdobeColorUtils"
  spec.version       = AdobeColorUtils::VERSION
  spec.authors       = ["Pat O'Neill"]
  spec.email         = ["Pat.Ryan.Oneill@gmail.com"]
  spec.summary       = %q{Read and Write support for Adobe Color Book Binary format.}
  spec.description   = %q{This gem allows the user to open and enumerate the colors in an ACB (Adobe Color Book) format file. It also has support for writing custom ACB files for use in Adobe applications.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
