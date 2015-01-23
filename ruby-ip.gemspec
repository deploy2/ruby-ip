Gem::Specification.new do |s|
  s.name = 'ruby-ip'
  s.version = '0.9.3'
  s.authors = ['Brian Candler']
  s.date = '2011-12-13'
  s.email = 'b.candler@pobox.com'
  s.summary = 'IP address manipulation library'
  s.homepage = 'http://github.com/deploy2/ruby-ip'
  s.description = 'IP address manipulation library'
  s.license = 'Ruby'

  s.files = Dir['lib/**/*.rb'] +
            Dir['test/**/*.rb'] +
            ['README.rdoc', 'Rakefile', 'LICENSE.txt', 'COPYING.txt']
  s.executables   = s.files.grep(/^bin\//) { |f| File.basename(f) }
  s.test_files    = s.files.grep(/^test\//)
  s.require_paths = ['lib']

  s.extra_rdoc_files = ['README.rdoc']
  s.has_rdoc = true
  s.rdoc_options = ['--inline-source', '--charset=UTF-8']
  s.rubyforge_project = 'ruby-ip'
  s.rubygems_version = '1.3.5'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
end
