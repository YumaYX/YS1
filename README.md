# YS1

home
: <https://github.com/YumaYX/YS1>

docs
: <https://yumayx.github.io/YS1>

## Description

YS1 is an indispensable toolkit and concept designed to be both convenient and useful, which I won’t want to forget. This toolkit is particularly valuable for basic information processing. It improves efficiency and accuracy in handling and managing information across a range of tasks.

## Installation

### gem Installation

```sh
git clone https://github.com/YumaYX/YS1.git && cd YS1 && gem build ys1.gemspec && gem install ys1*.gem --local
```

or

```sh
git clone https://github.com/YumaYX/YS1.git && cd YS1 && bundle install && bundle exec rake install:local
```

gem: Installs and manages gems globally or per Ruby version, handling only runtime dependencies from the gemspec and ignoring development dependencies.

### bundle Installation

```sh
cat <<'GEMFILEEOF' >> Gemfile
# frozen_string_literal: true
source "https://rubygems.org"
gem 'ys1', git: 'https://github.com/YumaYX/YS1.git'
GEMFILEEOF

bundle install
```

bundle: Installs and manages gems per project based on the Gemfile and Gemfile.lock, resolving both runtime and development dependencies and isolating them within the project.

### Offline Installation on RHEL Clones

Set up the environment using the following command.

```sh
# example @ AlmaLinux release 10.1 (Heliotrope Lion)
sudo dnf -y install "@Development Tools" ruby* # git make
```

Download the ZIP from GitHub, then run the rake and gem commands in that directory.

```sh
rake && gem build ys1.gemspec && gem install ys1*.gem --local
```


## Usage

in your codes:

```ruby
require "ys1"
```

- `gem install`: `ruby -rys1 -e 'p YS1::VERSION'`
- `bundle install`: `bundle exec ruby -rys1 -e 'p YS1::VERSION'`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/YumaYX/ys1.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

