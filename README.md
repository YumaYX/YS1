# YS1

home
: <https://github.com/YumaYX/YS1>

docs
: <https://yumayx.github.io/YS1>

## Installation

```sh
gem build ys1.gemspec
gem install ys1*.gem --local
# or
rake install:local
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
