Gem::Specification.new do |s|
  s.name = %q{ruby-ip}
  s.version = "0.9.2"

  s.required_rubygems_version = ">= 1.3.6" if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Candler"]
  s.date = %q{2011-12-13}
  s.description = %q{IP address manipulation library}
  s.email = %q{b.candler@pobox.com}
  s.files = Dir["lib/**/*.rb"] +
            Dir["test/**/*.rb"] +
            ["README.rdoc", "Rakefile", "LICENSE.txt", "COPYING.txt"]
  s.executables = []
  s.extra_rdoc_files = ["README.rdoc"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/deploy2/ruby-ip}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-ip}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{IP address manipulation library}
  if s.respond_to? :specification_version then
    s.specification_version = 2
  end
end
