# YS1

home
: <https://github.com/YumaYX/YS1>

docs
: <https://yumayx.github.io/YS1>

## Installation

### Local Install

```sh
gem build ys1.gemspec
gem install ys1*.gem --local
# or
rake install:local
```

### Install with Gemfile

in your Gemfile:

```ruby
source 'https://rubygems.pkg.github.com/YumaYX' do
  gem 'ys1'
end
```

## Usage

in your codes:

```ruby
require "ys1"

array = Ys1::CsvConverter.csv_to_array("sample.csv")
puts array
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/YumaYX/ys1.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
