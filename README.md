# YS1


[![Test](https://github.com/YumaYX/YS1/actions/workflows/test.yml/badge.svg?branch=workshop)](https://github.com/YumaYX/YS1/actions/workflows/test.yml)


home
: <https://github.com/YumaYX/YS1>

docs
: <https://yumayx.github.io/YS1>


## Description

YS1 is an indispensable toolkit and concept designed to be both convenient and useful, which I won’t want to forget. This toolkit is particularly valuable for basic information processing. It improves efficiency and accuracy in handling and managing information across a range of tasks.

## Installation

### A gem Installation

```sh
git clone https://github.com/YumaYX/YS1.git && cd YS1 && gem build ys1.gemspec && gem install ys1*.gem --local
```

or

```sh
git clone https://github.com/YumaYX/YS1.git && cd YS1 && bundle install && bundle exec rake install:local
```

gem: Installs and manages gems globally or per Ruby version, handling only runtime dependencies from the gemspec and ignoring development dependencies.

### B bundle Installation

```sh
cat <<'GEMFILEEOF' >> Gemfile
# frozen_string_literal: true
source "https://rubygems.org"
gem 'ys1', git: 'https://github.com/YumaYX/YS1.git'
GEMFILEEOF

bundle install
```

bundle: Installs and manages gems per project based on the Gemfile and Gemfile.lock, resolving both runtime and development dependencies and isolating them within the project.

### C Offline Installation on RHEL Clones

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

YS1::IP.netmask(24)
#=> "255.255.255.0"


ruby_info = { "version" => "4.0.0", "release_date" => "2025-12-25" }
#=> {"version" => "4.0.0", "release_date" => "2025-12-25"}

ruby_info.to_anon_class.new
#=> 
##<#<Class:0x0000000123f0a518>:0x0000000126893d80
# @release_date="2025-12-25",
# @version="4.0.0">
```

- `gem install`: `ruby -rys1 -e 'p YS1::VERSION'`
- `bundle install`: `bundle exec ruby -rys1 -e 'p YS1::VERSION'`

### Modules

```ruby
require "ys1"

# IP helpers
YS1::IP.include?("10.0.0.0/8", "10.1.2.3")   #=> true
YS1::IP.private?("192.168.1.1")             #=> true
YS1::IP.version("2001:db8::1")              #=> 6

# CSV reading and writing
csv = YS1::CSV.new("users.csv")
csv.select_columns("name", "email")
csv.cast("age" => :to_i)
puts csv.to_table
YS1::CSV.write("out.csv", [{ "name" => "Taro", "age" => 20 }])

# Fenced code blocks
YS1::CodeBlock.languages("```rb\nputs 1\n```\n```sh\nls\n```")
#=> ["rb", "sh"]
YS1::CodeBlock.strip_all("text\n```rb\nputs 1\n```")

# Cartesian product with an optional limit
YS1::Join.cross([1, 2], %w[a b], limit: 3).to_a
#=> [[1, "a"], [1, "b"], [2, "a"]]

# File helpers
YS1::Path.read_lines("ips.txt").first          #=> "10.0.0.1"

# Hierarchical tree rendering
YS1::ParentAndChild.new("root").to_tree

# Aligned tables, humanized values, and reports
puts YS1::Table.format([{ "name" => "Taro", "age" => 20 }])
YS1::Humanize.bytes(1536)            #=> "1.5 KiB"
YS1::Humanize.duration(3661)         #=> "1h 1m 1s"
YS1::Humanize.number(1_234_567)      #=> "1,234,567"
YS1::Report.save({ "count" => 3 }, "stats.dat")   #=> "stats.dat"
YS1::Report.load("stats.dat")                     #=> {"count" => 3}
```

### Ollama

Requires a running [Ollama](https://ollama.com) server at `http://localhost:11434`.

```ruby
require "ys1"

# Non-streaming generation (returns the response text)
YS1::Ollama.request("Give me one fun fact about Ruby.", model: "gemma4")
#=> "Ruby was created by Yukihiro Matsumoto."

# Streaming (yields chunks and returns the full text)
YS1::Ollama.stream("Tell me a short story.") { |chunk| print chunk }

# Structured extraction (returns parsed JSON)
YS1::Ollama::Extract.from_text(%({"name": string}), "I'm Taro.")
#=> {"name" => "Taro"}

# OCR: extract the text from an image
YS1::Ollama::OCR.from_file("scan.png", model: "gemma4")
#=> "Invoice #123"

# Translation (streams by default)
YS1::Ollama::Trans.into(:English, "こんにちは") { |chunk| print chunk }
```

The model name and model options are passed per call, so separate calls never
affect each other. `YS1::Ollama::DEFAULT_MODEL` is used when `model:` is omitted.

The command-line entry points are installed as executables:

```sh
ys1 "Tell me one fun fact about Ruby."   # stream a response
ys1-ocr scan.png                         # OCR an image
ys1-trans English "こんにちは"            # translate text
ys1-agg ips.txt                          # aggregate IPv4 addresses into ACL rules
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/YumaYX/YS1.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

