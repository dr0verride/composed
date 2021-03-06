# Composed

This is a small utility to help you define new types purely through **composition**. This way you can build all the small objects you want and put them together in a simple way.

## Quick Example

```ruby
#lib/report.rb
class Report
  def initialize(config, filter:, output_format:)
    @config = config
    @output_format = output_format
    @filter = filter
  end

# ... etc ...
end

#lib/json_report.rb
ImportantJSONReport = Composed(Report) do
  dependency(:output_format) { JSONFormatter.new }
  dependency(:filter) { ImportantStuffFilter.new }
end

#app/biz_report.rb
ImportantJSONReport.new(my_config).generate(data)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'composed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install composed

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dr0verride/composed.

