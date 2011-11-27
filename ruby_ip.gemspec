# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = "ruby-ip"
  s.version     = "0.9.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian Candler"]
  s.email       = ["durran@gmail.com"]
  s.homepage    = "https://github.com/deploy2/ruby-ip"
  s.summary     = "IP address manipulation library"
  s.description = s.summary

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "ruby-ip"

  s.add_development_dependency("rdoc", ["~> 3.5.0"])

  s.files        = Dir.glob("lib/**/*") + %w(COPYING.txt LICENSE.txt Rakefile README.rdoc)
  s.require_path = 'lib'
end