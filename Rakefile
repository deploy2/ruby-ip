require 'rake/clean'

task :gem => :build
task :build do
  system "gem build ruby-ip.gemspec"
end

#### TESTING ####
require 'rake/testtask'
task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

#### COVERAGE ####
begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/*_test.rb']
    t.verbose = true
    t.rcov_opts << '--exclude "gems/*"'
  end
rescue LoadError
end

#### DOCUMENTATION ####
require 'rdoc/task'
Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.template = ENV['template'] if ENV['template']
  rdoc.title    = "Ruby-IP Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

