# Periodoxical

_"Up, and down, and in the end, it's only round and round and round..._" - Pink Floyd, "Us and Them"

Generate periodic dates/times based on rules. Great for (but not limited to) calendar and scheduling applications. 
See Usage for examples/details.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'periodoxical'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install periodoxical

## Usage

```rb
# generates 9:00AM - 10:30AM and 2:00PM - 2:30PM time blocks
# on Mondays, Wednesdays, and Thursdays, between the dates of
# May 23, 2024 and June 24, 2024

Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  days_of_week: %w[mon wed thu],
  time_blocks: [
    {
      start_time: '9:00AM',
      end_time: '10:30AM'
    },
    {
      start_time: '2:00PM',
      end_time: '2:30PM'
    }
  ],
  start_date: Date.parse('2024-05-23'),
  end_date: Date.parse('2024-06-24')
)
# returns an array of hashes, each with a :start, :end
#=> 
[
    {
        :start=>#<DateTime: 2024-05-23T16:00:00+00:00>,
        :end=>#<DateTime: 2024-05-23T16:00:00+00:00>
    },
    {
        :start=>#<DateTime: 2024-05-23T16:00:00+00:00>,
        :end=>#<DateTime: 2024-05-23T16:00:00+00:00>
    },
    {
        :start=>#<DateTime: 2024-05-30T16:00:00+00:00>,
        :end=>#<DateTime: 2024-05-30T16:00:00+00:00>
    },
    {   :start=>#<DateTime: 2024-05-30T16:00:00+00:00>,
        :end=>#<DateTime: 2024-05-30T16:00:00+00:00>
    },

    ...
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/periodoxical. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Periodoxical project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/periodoxical/blob/master/CODE_OF_CONDUCT.md).
