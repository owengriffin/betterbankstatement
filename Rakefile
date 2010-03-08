require 'rubygems'
require 'less'
require 'fileutils'


task :gem => [:build]

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "betterbankstatement"
    gem.summary = %Q{A utility which converts statements from your bank into something a little more meaningful}
    gem.description = %Q{Imports PDF, Text, and QIF statements, generates statistics and hosts them on a WEBrick HTTP server. }
    gem.email = "owen.griffin@gmail.com"
    gem.homepage = "http://github.com/owengriffin/betterbankstatement"
    gem.authors = ["Owen Griffin"]
    gem.add_dependency "mechanize", ">= 0.9.3"
    gem.add_dependency "markaby", ">= 0.5"
    gem.add_dependency "hpricot", ">= 0.8.1"
    gem.add_dependency "json", ">= 1.2.0"
    gem.add_development_dependency "less", ">= 1.2.19"
    gem.files << ["filters.yaml", "style.css", "open-flash-chart.swf"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "betterbankstatement #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

