require 'rubygems'
require 'rake'
require 'rake/clean'
require 'spec/rake/spectask'

desc 'Default: run specs.'
task :default => :spec

desc 'Run all the specs for SMail::MIME.'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = false
end
