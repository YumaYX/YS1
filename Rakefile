# frozen_string_literal: true

require "bundler/gem_tasks"

task :podman do
  sh <<~CMD
    podman run --userns=keep-id --rm \
      -v #{Dir.pwd}:/app:Z \
      -w /app \
      docker.io/library/ruby:latest \
      bash -c 'bundle install && bundle exec rake'
  CMD
end

# TEST
require "rake/testtask"
Rake::TestTask.new do |t|
  t.test_files = FileList["test/test_*.rb"]
  t.verbose = true
  t.warning = true
end
# task test: [:clobber, "rubocop:autocorrect"]
task test: [:clobber]

# RUBOCOP
require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = %w[bin lib test Rakefile]
  t.options = ["--format", "simple"]
end

task :fix do
  Rake::Task["rubocop:autocorrect_all"].invoke
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
    sh %(bundle exec yard stats --list-undoc)
  end
end

# CLOBBER
require "rake/clean"
CLOBBER.include("_site", ".yardoc")

task default: %i[test rubocop yard]
