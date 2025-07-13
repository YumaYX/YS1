# YS1

home
: <https://github.com/YumaYX/YS1>

docs
: <https://yumayx.github.io/YS1>

## Description

YS1 is an indispensable toolkit and concept designed to be both convenient and useful, which I won’t want to forget. This toolkit is particularly valuable for basic information processing. It improves efficiency and accuracy in handling and managing information across a range of tasks.

## Installation

```sh
gem build ys1.gemspec
gem install ys1*.gem --local
```

or

```sh
rake install:local
```

or

```sh
cat <<'GEMFILEEOF' >> Gemfile
gem 'ys1', git: 'https://github.com/YumaYX/YS1.git'
GEMFILEEOF
bundle install
```

## Usage

in your codes:

```ruby
require "ys1"

array = YS1::Csv.to_array("sample.csv")
puts array
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/YumaYX/ys1.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
