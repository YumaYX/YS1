# frozen_string_literal: true

require "bundler/gem_tasks"

# ACT
desc "Test with act"
task :act do
  if RUBY_PLATFORM.include?("arm64")
    sh %(act -j test -W .github/workflows/test.yml --container-architecture linux/arm64)
  else
    sh %(sudo /root/bin/act -j test -W .github/workflows/test.yml)
  end
end

# Git
desc "Git Tag and Push"
task tag: :act do
  vtag = "v#{YS1::VERSION}"
  sh %(git tag #{vtag})
  sh %(git push origin #{vtag})
end

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
CLOBBER.include("testdata/csv_converter/*.json", "input", "_site", ".yardoc")

task default: %i[test rubocop yard]
