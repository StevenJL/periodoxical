# Periodoxical

_"Up, and down, and in the end, it's only round and round and round..._" - Pink Floyd, "Us and Them"

<div align="center">
  <img width="558" alt="pink_floyd_time" src="https://github.com/StevenJL/periodoxical/assets/2191808/8bab4a14-2df7-42d0-b6ae-f6b57a353500">
    <p><i>(Image Courtesy of "Pink Floyd: Time," directed by Ian Eames , ©1973)</i></p>
</div>

<br>

Generate periodic datetime blocks based on provided rules/conditions. Great for (but not limited to) calendar and scheduling applications. See Usage for detailed examples.

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

### Example 1
As a Ruby dev, I want to generate all the datetime blocks of **9:00AM - 10:30AM** for all days from **May 23, 2024** to **May 26, 2024** inclusive.

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  time_blocks: [
    {
      start_time: '9:00AM',
      end_time: '10:30AM'
    },
  ],
  start_date: '2024-05-23',
  end_date: '2024-05-27',
)
#=> 
[
    {
     start_time: #<DateTime: 2024-05-23T09:00:00-0700>,
     end_time: #<DateTime: 2024-05-23T10:30:00-0700>,
    },
    {
     start_time: #<DateTime: 2024-05-24T09:00:00-0700>,
     end_time: #<DateTime: 2024-05-24T10:30:00-0700>,
    },
    {
     start_time: #<DateTime: 2024-05-25T09:00:00-0700>,
     end_time: #<DateTime: 2024-05-25T10:30:00-0700>,
    },
    {
     start_time: #<DateTime: 2024-05-26T09:00:00-0700>,
     end_time: #<DateTime: 2024-05-26T10:30:00-0700>,
    }
]
```

### Example 2 - specify days of the week
As a Ruby dev, I want to generate all the datetime blocks of **9:00AM - 10:30AM** and **2:00PM - 2:30PM**, on **Mondays**, **Wednesdays**, and **Thursdays**, between the dates of **May 23, 2024** and **June 12, 2024**, inclusive. This can be represented visually as:

<div align="center">
  <img width="558" alt="calendar_image_1" src="https://github.com/StevenJL/periodoxical/assets/2191808/e92fc6ff-03fd-44ed-a955-d3a0dd0f5d0a">
    <p><i>(image courtesy of Cal.com)</i></p>
</div>

<br>

```rb
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
  start_date: '2024-05-23',
  end_date: '2024-06-12',
)
# returns an array of hashes, each with :start and :end keys
#=> 
[
  {
    start: #<DateTime: 2024-05-23T09:00:00-0700">,
    end:   #<DateTime: 2024-05-23T22:30:00-0700">,
  },
  {
    start: #<DateTime: 2024-05-23T14:00:00-0700>,
    end:   #<DateTime: 2024-05-23T14:30:00-0700>,
  },
 {
    start: #<DateTime: 2024-05-27T09:00:00-0700>,
    end:   #<DateTime: 2024-05-27T22:30:00-0700>
 },
 ...
 {
    start: #<DateTime: 2024-06-12T14:00:00-0700>,
    end:   #<DateTime: 2024-06-12T14:30:00-0700>
 }
]
```

### Example 3 - using the `limit` key.

As a ruby dev, I want to generate the next **3** datetime blocks of **9:00AM - 10:30AM** and **2:00PM - 2:30PM** on **Sundays**, after **May 23, 2024** using the `limit` key.

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  days_of_week: %w[sun],
  time_blocks: [
    {
      start_time: '9:00AM',
      end_time: '10:30PM'
    },
    {
      start_time: '2:00PM',
      end_time: '2:30PM'
    }
  ],
  start_date: Date.parse('2024-05-23'), # Can also pass in `Date` object.
  limit: 3
)
# =>
[
  {
    start: #<DateTime: 2024-05-26T09:00:00-0700>,
    end:   #<DateTime: 2024-05-26T22:30:00-0700>,
  },
  {
    start: #<DateTime: 2024-05-26T14:00:00-0700>,
    end:   #<DateTime: 2024-05-26T14:30:00-0700>,
  },
  {
    start: #<DateTime: 2024-06-02T09:00:00-0700>,
    end:   #<DateTime: 2024-06-02T22:30:00-0700>,
  },
]
```

### Example 4 - when time blocks vary between days

As a ruby dev, I want to generate all the timeblocks between **May 23, 2024** and **June 12, 2024** where the time should be **8AM-9AM** on **Mondays**, but **10:45AM-12:00PM** and **2:00PM-4:00PM** on **Wednesdays**, and **2:30PM-4:15PM** on **Thursdays**.

<div align="center">
  <img width="628" alt="calendar_image_2" src="https://github.com/StevenJL/periodoxical/assets/2191808/26d14824-08ff-481a-97e2-9b6b11beea29">
  <p><i>(image courtesy of Cal.com)</i></p>
</div>

<br>

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: Date.parse('2024-05-23'), # can also pass in Date objects
  end_date: Date.parse('2024-06-12'), # can also pass in Date objects,
  day_of_week_time_blocks: {
    mon: [
      { start_time: '8:00AM', end_time: '9:00AM' },
    ],
    wed: [
      { start_time: '10:45AM', end_time: '12:00PM' },
      { start_time: '2:00PM', end_time: '4:00PM' },
    ],
    thu: [
      { start_time: '2:30PM', end_time: '4:15PM' }
    ],
  }
)
```

### Example 5 - when specifying time blocks by day-of-month and/or and/or week-of-month and/or month.

As a Ruby dev, I want to generate the next 3 slots for **8AM - 9AM** for the **5th** and **10th** day of every month starting from **June**

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: '2024-06-1',
  limit: 3,
  days_of_month: [5, 10],
  time_blocks: [
    { start_time: '8:00AM', end_time: '9:00AM' },
  ],
)
#=>
[
    {
      start: #<DateTime: 2024-06-05 08:00:00 -0700>,
      end: #<DateTime: 2024-06-05 09:00:00 -0700>,
    },
    {
      start: #<DateTime: 2024-06-10 08:00:00 -0700>,
      end: #<DateTime: 2024-06-10 09:00:00 -0700>,
    },
    {
      start: #<DateTime: 2024-07-05 08:00:00 -0700>,
      end: #<DateTime: 2024-07-05 09:00:00 -0700>,
    },
]
```

As a Ruby dev, I want to generate **4** slots for **8AM - 9AM** on **Mondays** but only in the **first two weeks** in the months of **April, May, and June**

```
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: '2024-04-1',
  limit: 4,
  weeks_of_month: [1 2],
  months: [4, 5, 6],
  days_of_week: %w(mon),
  time_blocks: [
    { start_time: '8:00AM', end_time: '9:00AM' },
  ],
)
#=> 
[
    {
     start_time: #<DateTime: 2024-04-01 08:00:00 -0700>,
     end_time: #<DateTime: 2024-04-01 09:00:00 -0700>,
    },
    {
     start_time: #<DateTime: 2024-04-08 08:00:00 -0700>,
     end_time: #<DateTime: 2024-04-08 09:00:00 -0700>,
    },
    {
     start_time: #<DateTime: 2024-05-06 08:00:00 -0700>,
     end_time: #<DateTime: 2024-05-06 09:00:00 -0700>,
    },
    {
     start_time: #<DateTime: 2024-06-03 08:00:00 -0700>,
     end_time: #<DateTime: 2024-06-03 09:00:00 -0700>,
    },
]
```

### Example 6 - Exclude time blocks using the `exclusion_dates` parameter
As a Ruby dev, I want to generate slots for **8AM - 9AM** on **Mondays**, except for the **Monday of June 10, 2024**.

```rb
Periodoxical.generate(
  time_zone: 'America/Los_Angeles',
  start_date: '2024-06-3',
  limit: 4,
  exclusion_dates: %w(2024-06-10),
  day_of_week_time_blocks: {
    mon: [
      { start_time: '8:00AM', end_time: '9:00AM' },
    ],
  }
)
# Returns all Monday 8AM - 9AM blocks except for the Monday on June 10, 2024
# => 
[
    {
      start: #<DateTime: 2024-06-03T08:00:00-0700>,
      end: #<DateTime: 2024-06-03T09:00:00-0700>,
    }
    {
      start: #<DateTime: 2024-06-17T08:00:00-0700>,
      end: #<DateTime: 2024-06-17T09:00:00-0700>,
    }
    {
      start: #<DateTime: 2024-06-24T08:00:00-0700>,
      end: #<DateTime: 2024-06-24T09:00:00-0700>,
    }
    {
      start: #<DateTime: 2024-07-01T08:00:00-0700>,
      end: #<DateTime: 2024-07-01T09:00:00-0700>,
    }
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
