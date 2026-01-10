# frozen_string_literal: true

require "bundler/gem_tasks"

# TEST
require "rake/testtask"
Rake::TestTask.new do |t|
  t.test_files = FileList["test/test_*.rb"]
  t.warning = true
end
task test: :clobber

# RUBOCOP
require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = %w[bin lib test Rakefile]
  t.options = ["--format", "simple"]
end

# YARD
require "yard"
YARD::Rake::YardocTask.new do |t|
  t.files = FileList.new %w[lib/*.rb lib/**/*.rb]
  t.options += ["--output-dir", "_site"]
end
task yard: :clobber

namespace :yard do
  desc "Show YARD stats"
  task :stat do
    sh %(yard stats --list-undoc)
  end
end

# CLOBBER
require "rake/clean"
CLOBBER.include("testdata/csv_converter/*.json", "input", "_site", ".yardoc", "**/listfiles.md")

task default: %i[test rubocop yard]
