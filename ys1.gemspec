# frozen_string_literal: true

require_relative "lib/ys1/version"

Gem::Specification.new do |spec|
  spec.name = "ys1"
  spec.version = YS1::VERSION
  spec.authors = ["Yuma"]
  spec.email = ["86939129+YumaYX@users.noreply.github.com"]

  spec.summary = "My Essential"
  spec.description = "YS1 is an indispensable toolkit and concept designed to be both convenient and useful, which I won’t want to forget. This toolkit is particularly valuable for basic information processing. It improves efficiency and accuracy in handling and managing information across a range of tasks."
  spec.homepage = "https://github.com/YumaYX/YS1"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3"

  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/YumaYX"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  {
    csv:      nil,
    minitest: nil,
    rake:     nil,
    rdoc:     nil,
    rubocop: nil,
    yard:    nil,
  }.each do |dep, version|
    spec.add_dependency(dep.to_s, version)
  end

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
