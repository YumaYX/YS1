# AGENTS.md

## Project Overview

YS1 is a personal utility gem ("My Essential") providing small, focused tools for
basic information processing: IP/CIDR handling, CSV conversion, Cartesian products,
dynamic objects, code-block parsing, Ollama LLM integration, and more.

- Language: Ruby (>= 3.0)
- Namespace: `YS1`
- License: MIT
- Docs: https://yumayx.github.io/YS1 (YARD → `_site`)

## Project Structure

```
lib/
  ys1.rb                  # entry point; auto-requires everything under lib/ys1/**/
  ys1/
    version.rb            # YS1::VERSION
    <module>.rb           # one module/class per feature (YS1::<Module>)
    <module>/             # submodules for complex features (ip/, ollama/)
    core_ext/             # monkey-patches (Hash, Integer, String)
test/
  helper.rb               # $LOAD_PATH setup + minitest/autorun
  test_<module>.rb        # mirrors lib/ys1/<module>.rb
  ollama/                 # online tests requiring a running Ollama server
bin/
  setup                   # bundle install
  console                 # IRB with ys1 loaded
  addmod                  # scaffolding script (bin/addmod <name>)
exe/                      # installed executables (ys1, ys1-ocr, ys1-trans, ys1-agg)
sig/ys1.rbs               # RBS type signatures
```

New files under `lib/ys1/` are auto-required by the `Dir.glob` in `lib/ys1.rb` —
no manual require is needed for top-level or nested `lib/ys1/**/*.rb` files.

## Development Commands

```sh
bundle exec rake test           # run all offline tests (default task prerequisite)
bundle exec rake test:ollama    # run online Ollama tests (needs localhost:11434)
bundle exec rake rubocop        # lint (bin exe lib test Rakefile)
bundle exec rake fix            # RuboCop autocorrect-all
bundle exec rake yard           # generate YARD docs into _site/
bundle exec yard stats --list-undoc   # YARD coverage report
bundle exec rake init           # bundle install + rake (full build)
bundle exec rake podman         # run full test suite in a podman container
bin/console                    # IRB with ys1 loaded
```

The default rake task runs `test`, `rubocop`, and `yard` (when rubocop/yard gems
are available). Always run `bundle exec rake` before committing.

CI (GitHub Actions) runs tests on Ruby 3.0–4.0; the Test workflow is triggered
after the RuboCop workflow completes.

## Code Conventions

- Every file starts with `# frozen_string_literal: true`.
- Strings use double quotes (RuboCop `Style/StringLiterals: double_quotes`).
- Target Ruby 3.0+; endless methods (`def addr = @ip.to_s`) are acceptable.
- Public module APIs use the `class << self` singleton pattern; helper methods
  go after `private` inside the `class << self` block.
- Internal requires use `require_relative`; stdlib/gem requires use `require`.
- Guard CLI entry points with `if __FILE__ == $PROGRAM_NAME`.
- Namespace everything under `YS1` (e.g. `YS1::IP::Aggregator`).
- Core extensions live in `lib/ys1/core_ext/` and reopen the stdlib class directly.

### Documentation (YARD)

- Every public class, module, and method must have YARD comments.
- Use `@param`, `@return`, `@raise`, `@example`, and `@see` tags.
- `@example` blocks are the primary documentation vehicle — include realistic
  usage with expected output (`# => value`).
- Keep `bundle exec yard stats --list-undoc` at 0 undocumented public objects.

### Type Signatures

- Update `sig/ys1.rbs` when adding or changing public API surface.

## Testing Conventions

- Framework: Minitest (`Minitest::Test`).
- File naming: `test/test_<module>.rb` mirrors `lib/ys1/<module>.rb`.
- Class naming: `TestYS1<Module>` (e.g. `TestYS1IP`, `TestYS1Join`).
- Always `require_relative "helper"` — never `require "ys1"` directly in tests.
- Use `setup`/`teardown` for per-test state; prefer instance variables set in
  `setup`.
- Test both success paths and error paths (`assert_raises`, `refute_respond_to`).
- Online tests (Ollama) live in `test/ollama/` and are excluded from the default
  suite; run them with `rake test:ollama` only when a local Ollama server is up.
  Shared constants (e.g. `TEST_OLLAMA_MODEL`) go in `test/ollama/ollama_helper.rb`.

## Adding a New Feature

1. Create `lib/ys1/<name>.rb` defining `YS1::<Name>` (auto-required).
2. Create `test/test_<name>.rb` with class `TestYS1<Name>`.
3. Add YARD docs with `@example` to every public method.
4. Update `sig/ys1.rbs` for the new public API.
5. Run `bundle exec rake` (tests + rubocop + yard) and fix any issues.

Tip: `bin/addmod <name>` scaffolds both `lib/ys1/<name>.rb` and
`test/test_<name>.rb` for you.

## Quality Checklist

- [ ] `bundle exec rake` passes (test + rubocop + yard)
- [ ] New public methods have YARD docs with `@example`
- [ ] Tests cover happy path and edge/error cases
- [ ] `sig/ys1.rbs` updated for API changes
- [ ] No RuboCop offenses (run `rake fix` for autocorrections first)
- [ ] Version bumped in `lib/ys1/version.rb` for releases
