require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'oxmlk'
    gem.summary = %Q{Object 2 XML kit for ruby}
    gem.description = %Q{OxMlk gives you a simple way to map you ruby objects to XML and then convert one to the other.}
    gem.email = 'hexorx@gmail.com'
    gem.homepage = 'http://github.com/hexorx/oxmlk'
    gem.authors = ['Josh Robinson']
    gem.add_development_dependency 'rspec'
    gem.add_dependency 'libxml-ruby'
    gem.add_dependency 'activesupport', '>= 2.1.0'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler'
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts = ['--options', 'spec/spec.opts']
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "oxmlk #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
